import 'dart:math' as math; // Random dan fungsi matematika
import 'package:flutter/material.dart'; // widget dasar Flutter
import 'package:flutter/scheduler.dart'; // Ticker: detak per bingkai layar
import 'package:flutter/services.dart'; // HapticFeedback (getaran halus)
import 'package:provider/provider.dart'; // membaca provider

import '../../../core/database/database_helper.dart'; // simpan rekor
import '../../../core/theme/app_theme.dart'; // warna aplikasi
import '../../../core/widgets/tuban_scene.dart'; // latar kebun siwalan
import '../../achievements/widgets/achievement_widgets.dart'; // toast lencana
import '../../coin/providers/coin_provider.dart'; // koin
import '../../coin/widgets/reward_dialog.dart'; // pop-up hadiah

/// Jenis benda yang jatuh.
enum DropType { siwalan, emas, legen, busuk } // buah biasa, buah emas, minuman legen, buah busuk

/// Satu benda yang sedang jatuh (posisi dalam piksel).
class _Drop {
  final DropType type; // jenis benda
  double x; // posisi mendatar (piksel)
  double y; // posisi tegak (piksel)
  final double vy; // kecepatan jatuh (piksel per detik)
  double rot; // sudut putar saat ini
  final double spin; // kecepatan putar (radian per detik)
  _Drop(this.type, this.x, this.y, this.vy, this.rot, this.spin); // konstruktor
}

/// Teks melayang ("+3", "Combo!") yang naik lalu memudar.
class _Pop {
  final String text; // isi teks
  final Color color; // warna teks
  double x; // posisi mendatar
  double y; // posisi tegak
  double life; // sisa umur (detik)
  _Pop(this.text, this.color, this.x, this.y, this.life); // konstruktor
}

/// Tahapan permainan.
enum _Phase { ready, countdown, playing, paused, done } // siap, hitung mundur, main, jeda, selesai

/// Game ketangkasan: geser keranjang anyaman untuk menangkap buah siwalan segar.
/// Buah emas bernilai besar, legen menambah waktu, buah busuk mengurangi nyawa.
class SiwalanGameScreen extends StatefulWidget {
  const SiwalanGameScreen({super.key}); // konstruktor konstan

  @override
  State<SiwalanGameScreen> createState() => _SiwalanGameScreenState(); // buat state
}

class _SiwalanGameScreenState extends State<SiwalanGameScreen> with SingleTickerProviderStateMixin {
  static const double _basketW = 104; // lebar keranjang (piksel)
  static const double _basketH = 44; // tinggi keranjang (piksel)
  static const double _dropR = 17; // jari-jari benda jatuh (piksel)
  static const double _gameSeconds = 30; // lama permainan (detik)

  final math.Random _rng = math.Random(); // pembuat angka acak
  final List<_Drop> _drops = []; // benda yang sedang jatuh
  final List<_Pop> _pops = []; // teks melayang
  final ValueNotifier<int> _frame = ValueNotifier<int>(0); // pemicu gambar ulang kanvas tiap bingkai
  late final Ticker _ticker; // detak bingkai
  Duration _last = Duration.zero; // waktu bingkai sebelumnya

  _Phase _phase = _Phase.ready; // tahap saat ini
  double _w = 0, _h = 0; // ukuran area bermain
  double _basketX = -1; // pusat keranjang (piksel); -1 = belum diatur
  double _bump = 0; // efek keranjang "membal" saat menangkap (0..1)
  double _countdown = 3; // sisa hitung mundur (detik)
  double _timeLeft = _gameSeconds; // sisa waktu main (detik)
  double _spawnIn = 0.4; // jeda sampai benda berikutnya muncul
  double _played = 0; // lama sudah bermain (untuk menaikkan kesulitan)
  int _score = 0; // poin
  int _caught = 0; // jumlah buah segar tertangkap
  int _combo = 0; // tangkapan beruntun tanpa meleset
  int _bestCombo = 0; // combo tertinggi pada permainan ini
  int _lives = 3; // nyawa tersisa

  @override
  void initState() { // dipanggil sekali
    super.initState(); // panggil induk
    _ticker = createTicker(_onTick); // buat ticker
  }

  @override
  void dispose() { // dipanggil saat layar ditutup
    _ticker.dispose(); // hentikan ticker
    _frame.dispose(); // bebaskan pemicu gambar
    super.dispose(); // panggil induk
  }

  /// Memulai hitung mundur 3-2-1.
  void _start() { // mulai
    _phase = _Phase.countdown; // masuk hitung mundur
    _countdown = 3; // atur ulang hitung mundur
    _last = Duration.zero; // atur ulang jam
    _ticker.start(); // jalankan ticker
    setState(() {}); // gambar ulang tampilan
  }

  /// Dipanggil tiap bingkai layar: menggerakkan seluruh isi permainan.
  void _onTick(Duration elapsed) { // elapsed = waktu sejak ticker dimulai
    final dt = ((elapsed - _last).inMicroseconds / 1e6).clamp(0.0, 0.05).toDouble(); // selisih waktu (dibatasi agar tidak melompat)
    _last = elapsed; // simpan waktu bingkai ini
    if (_phase == _Phase.countdown) { // sedang hitung mundur
      _countdown -= dt; // kurangi waktu hitung mundur
      if (_countdown <= 0) { _phase = _Phase.playing; setState(() {}); } // mulai main
    } else if (_phase == _Phase.playing) { // sedang bermain
      _step(dt); // jalankan logika permainan
    }
    _frame.value++; // minta kanvas digambar ulang
  }

  /// Logika satu langkah waktu [dt] detik.
  void _step(double dt) { // langkah permainan
    _timeLeft -= dt; // waktu berkurang
    _played += dt; // lama main bertambah
    _bump = math.max(0, _bump - dt * 4); // efek membal mereda
    _spawnIn -= dt; // hitung mundur kemunculan benda
    if (_spawnIn <= 0) { // saatnya benda baru
      _spawn(); // munculkan
      _spawnIn = math.max(0.30, 0.85 - _played * 0.014) * (0.8 + _rng.nextDouble() * 0.4); // jeda makin pendek seiring waktu
    }
    final basketTop = _h - 74; // tepi atas keranjang
    for (final d in _drops) { d.y += d.vy * dt; d.rot += d.spin * dt; } // gerakkan dan putar semua benda
    final remove = <_Drop>[]; // benda yang dihapus pada langkah ini
    for (final d in _drops) { // periksa tiap benda
      final caught = d.y + _dropR >= basketTop && d.y - _dropR <= basketTop + 22 && (d.x - _basketX).abs() <= _basketW / 2 + 4; // menyentuh mulut keranjang?
      if (caught) { _onCatch(d); remove.add(d); } // tangkap
      else if (d.y - _dropR > _h) { // jatuh melewati dasar layar
        if (d.type == DropType.siwalan || d.type == DropType.emas) { // buah bagus lolos
          if (_combo > 0) _pop('Lolos!', Colors.white70, d.x, _h - 90); // beri tahu combo putus
          _combo = 0; // combo putus
        }
        remove.add(d); // hapus benda
      }
    }
    _drops.removeWhere(remove.contains); // buang benda yang selesai
    for (final p in _pops) { p.y -= 46 * dt; p.life -= dt; } // teks melayang naik dan memudar
    _pops.removeWhere((p) => p.life <= 0); // buang teks yang habis umur
    if (_timeLeft <= 0 || _lives <= 0) _finish(); // waktu atau nyawa habis
  }

  /// Memunculkan satu benda di atas layar dengan peluang menurut jenis.
  void _spawn() { // munculkan benda
    final r = _rng.nextDouble(); // angka acak 0..1
    final badChance = 0.12 + math.min(0.10, _played * 0.004); // peluang buah busuk naik pelan
    final type = r < 0.07 ? DropType.emas : r < 0.14 ? DropType.legen : r < 0.14 + badChance ? DropType.busuk : DropType.siwalan; // pilih jenis
    final speed = _h * (0.34 + _played * 0.006 + _rng.nextDouble() * 0.14); // kecepatan jatuh (piksel/detik)
    final x = _dropR + _rng.nextDouble() * (_w - _dropR * 2); // posisi mendatar acak
    _drops.add(_Drop(type, x, -_dropR, speed, _rng.nextDouble() * 6, (_rng.nextDouble() - 0.5) * 3)); // tambahkan benda
  }

  /// Pengali poin menurut combo.
  int get _multiplier => _combo >= 10 ? 3 : _combo >= 5 ? 2 : 1; // x3 di combo 10, x2 di combo 5

  /// Aturan saat benda tertangkap.
  void _onCatch(_Drop d) { // tangkap
    _bump = 1; // keranjang membal
    switch (d.type) { // sesuai jenis benda
      case DropType.siwalan: // buah segar
        _combo++; _caught++; // combo dan jumlah naik
        final pts = 3 * _multiplier; // poin dengan pengali
        _score += pts; // tambah skor
        _pop('+$pts', Colors.white, d.x, _h - 100); // teks poin
        HapticFeedback.selectionClick(); // getaran halus
        break;
      case DropType.emas: // buah emas
        _combo++; _caught++; // combo dan jumlah naik
        final pts = 10 * _multiplier; // poin besar
        _score += pts; // tambah skor
        _pop('+$pts EMAS!', AppColors.gold, d.x, _h - 100); // teks emas
        HapticFeedback.mediumImpact(); // getaran lebih kuat
        break;
      case DropType.legen: // minuman legen
        _timeLeft = math.min(_timeLeft + 4, _gameSeconds + 8); // tambah 4 detik (maksimal 8 detik di atas awal)
        _score += 2; // sedikit poin
        _pop('+4 dtk Legen', const Color(0xFFFFE082), d.x, _h - 100); // teks waktu
        HapticFeedback.selectionClick(); // getaran halus
        break;
      case DropType.busuk: // buah busuk
        _lives--; // nyawa berkurang
        _combo = 0; // combo putus
        _pop('Busuk! -1', const Color(0xFFFF8A80), d.x, _h - 100); // teks hukuman
        HapticFeedback.heavyImpact(); // getaran kuat
        break;
    }
    if (_combo > _bestCombo) _bestCombo = _combo; // catat combo terbaik
    if (_combo == 5 || _combo == 10) _pop('COMBO x$_combo! pengali naik', AppColors.gold, _w / 2, _h * 0.35); // sorotan pengali naik
  }

  void _pop(String text, Color color, double x, double y) => _pops.add(_Pop(text, color, x, y, 0.9)); // tambah teks melayang

  /// Akhir permainan: simpan koin, rekor, lencana, lalu tampilkan hadiah.
  Future<void> _finish() async { // selesai
    if (_phase == _Phase.done) return; // cegah dipanggil dua kali
    _phase = _Phase.done; // tandai selesai
    _ticker.stop(); // hentikan ticker
    final coins = _score; // satu poin = satu koin
    final coinProvider = context.read<CoinProvider>(); // ambil penyedia koin
    await coinProvider.addCoins(coins); // simpan koin ke SQLite
    final old = int.tryParse(await DatabaseHelper.instance.getGameState('best_siwalan') ?? '0') ?? 0; // rekor lama
    final isRecord = _score > old; // rekor baru?
    if (isRecord) await DatabaseHelper.instance.setGameState('best_siwalan', '$_score'); // simpan rekor
    if (!mounted) return; // pastikan layar masih ada
    if (_score >= 60) await unlockWithToast(context, 'jawara_siwalan'); // lencana jawara
    if (!mounted) return; // pastikan layar masih ada
    await showRewardDialog(context, coins: coins, message: '$_caught buah tertangkap · combo terbaik x$_bestCombo${isRecord ? '\nRekor baru!' : ''}'); // pop-up hadiah
    if (mounted) Navigator.pop(context); // kembali ke menu game
  }

  void _togglePause() { // jeda atau lanjut
    if (_phase == _Phase.playing) { _phase = _Phase.paused; } // jeda
    else if (_phase == _Phase.paused) { _phase = _Phase.playing; _last = Duration.zero; } // lanjut (jam diatur ulang agar tidak melompat)
    setState(() {}); // gambar ulang tampilan
  }

  @override
  Widget build(BuildContext context) { // membangun layar game
    return Scaffold( // kerangka layar
      appBar: AppBar( // bilah atas
        title: const Text('Ketangkasan Siwalan'), // judul
        actions: [
          if (_phase == _Phase.playing || _phase == _Phase.paused) // tombol jeda saat main
            IconButton(onPressed: _togglePause, icon: Icon(_phase == _Phase.paused ? Icons.play_arrow : Icons.pause)), // ikon jeda/lanjut
        ],
      ),
      body: LayoutBuilder( // ukur ruang bermain
        builder: (context, box) { // box berisi lebar dan tinggi
          _w = box.maxWidth; _h = box.maxHeight; // simpan ukuran
          if (_basketX < 0) _basketX = _w / 2; // letakkan keranjang di tengah pada awal
          return GestureDetector( // tangkap geseran jari
            behavior: HitTestBehavior.opaque, // seluruh area peka sentuh
            onPanUpdate: (d) { // saat jari bergeser
              if (_phase != _Phase.playing && _phase != _Phase.countdown && _phase != _Phase.ready) return; // abaikan saat jeda/selesai
              _basketX = (_basketX + d.delta.dx).clamp(_basketW / 2, _w - _basketW / 2).toDouble(); // geser dan batasi di dalam layar
              _frame.value++; // gambar ulang
            },
            child: Stack(children: [
              const Positioned.fill(child: TubanScene(kind: SceneKind.siwalan, phase: 0)), // latar kebun siwalan
              Positioned.fill(child: CustomPaint(painter: _GamePainter(this, _frame))), // benda jatuh, keranjang, teks
              _hud(), // papan skor
              if (_phase == _Phase.ready) _overlay(child: _intro()), // layar pembuka
              if (_phase == _Phase.countdown) _overlay(child: Text(_countdown.ceil().toString(), style: const TextStyle(fontSize: 96, fontWeight: FontWeight.w900, color: Colors.white))), // angka hitung mundur
              if (_phase == _Phase.paused) _overlay(child: const Text('Jeda', style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: Colors.white))), // tulisan jeda
            ]),
          );
        },
      ),
    );
  }

  /// Papan skor: poin, pengali, nyawa, dan bilah waktu. Diperbarui lewat ValueListenableBuilder.
  Widget _hud() { // papan skor
    return Positioned(top: 8, left: 12, right: 12, child: ValueListenableBuilder<int>(
      valueListenable: _frame, // perbarui tiap bingkai
      builder: (_, __, ___) => Column(children: [
        Row(children: [
          _chip(Icons.star, '$_score', AppColors.gold), // poin
          const SizedBox(width: 8), // jarak
          if (_multiplier > 1) _chip(Icons.bolt, 'x$_multiplier', const Color(0xFFFF7043)), // pengali combo
          const Spacer(), // dorong ke kanan
          for (int i = 0; i < 3; i++) Icon(i < _lives ? Icons.favorite : Icons.favorite_border, color: const Color(0xFFE53935), size: 24), // tiga nyawa
        ]),
        const SizedBox(height: 8), // jarak
        ClipRRect(borderRadius: BorderRadius.circular(6), child: LinearProgressIndicator(value: (_timeLeft / (_gameSeconds + 8)).clamp(0.0, 1.0).toDouble(), minHeight: 8, color: _timeLeft < 8 ? AppColors.red : AppColors.gold, backgroundColor: Colors.black26)), // bilah waktu
      ]),
    ));
  }

  Widget _chip(IconData icon, String text, Color color) => Container( // lencana kecil di papan skor
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), // jarak dalam
    decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)), // latar gelap bulat
    child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, color: color, size: 18), const SizedBox(width: 4), Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800))]), // ikon dan teks
  );

  Widget _overlay({required Widget child}) => Positioned.fill(child: Container(color: Colors.black38, child: Center(child: child))); // lapisan gelap berisi widget di tengah

  /// Kartu petunjuk sebelum mulai.
  Widget _intro() { // petunjuk
    Widget row(Widget icon, String t) => Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(children: [SizedBox(width: 30, height: 30, child: icon), const SizedBox(width: 10), Expanded(child: Text(t))])); // satu baris petunjuk
    return Container(
      margin: const EdgeInsets.all(24), padding: const EdgeInsets.all(20), // jarak luar dan dalam
      decoration: BoxDecoration(color: AppColors.cream, borderRadius: BorderRadius.circular(22)), // kartu krem
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('Tangkap Siwalan!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.greenDark)), // judul
        const SizedBox(height: 4), // jarak
        const Text('Geser jari ke kiri-kanan untuk menggerakkan keranjang.', textAlign: TextAlign.center), // cara main
        const SizedBox(height: 10), // jarak
        row(CustomPaint(painter: _IconPainter(DropType.siwalan)), 'Siwalan segar +3 (combo 5 = x2, combo 10 = x3)'), // petunjuk buah
        row(CustomPaint(painter: _IconPainter(DropType.emas)), 'Siwalan emas +10'), // petunjuk emas
        row(CustomPaint(painter: _IconPainter(DropType.legen)), 'Legen: tambah waktu 4 detik'), // petunjuk legen
        row(CustomPaint(painter: _IconPainter(DropType.busuk)), 'Buah busuk: kurangi 1 nyawa!'), // petunjuk busuk
        const SizedBox(height: 14), // jarak
        FilledButton.icon(onPressed: _start, icon: const Icon(Icons.play_arrow), label: const Text('Mulai')), // tombol mulai
      ]),
    );
  }
}

/// Pelukis ikon kecil untuk kartu petunjuk (menggambar satu benda di tengah).
class _IconPainter extends CustomPainter {
  final DropType type; // jenis benda
  const _IconPainter(this.type); // konstruktor
  @override
  void paint(Canvas canvas, Size size) => _drawDrop(canvas, type, size.center(Offset.zero), 12, 0); // gambar benda di tengah
  @override
  bool shouldRepaint(covariant CustomPainter old) => false; // statis
}

/// Pelukis utama: benda jatuh, keranjang, dan teks melayang.
class _GamePainter extends CustomPainter {
  final _SiwalanGameScreenState s; // state permainan (sumber data)
  _GamePainter(this.s, Listenable repaint) : super(repaint: repaint); // gambar ulang tiap bingkai

  @override
  void paint(Canvas canvas, Size size) { // menggambar
    for (final d in s._drops) { _drawDrop(canvas, d.type, Offset(d.x, d.y), _SiwalanGameScreenState._dropR, d.rot); } // semua benda jatuh
    _drawBasket(canvas, Offset(s._basketX, size.height - 74), s._bump); // keranjang
    for (final p in s._pops) { // teks melayang
      final tp = TextPainter(
        text: TextSpan(text: p.text, style: TextStyle(color: p.color.withAlpha((255 * (p.life / 0.9)).clamp(0, 255).toInt()), fontSize: 18, fontWeight: FontWeight.w900, shadows: const [Shadow(blurRadius: 4, color: Colors.black87)])), // gaya teks dengan bayangan agar terbaca
        textDirection: TextDirection.ltr, // arah teks
      )..layout(); // ukur teks
      tp.paint(canvas, Offset((p.x - tp.width / 2).clamp(4, size.width - tp.width - 4).toDouble(), p.y)); // gambar di dalam layar
    }
  }

  @override
  bool shouldRepaint(_GamePainter old) => true; // selalu gambar ulang tiap bingkai
}

/// Menggambar satu benda jatuh di pusat [c] dengan jari-jari [r] dan putaran [rot].
void _drawDrop(Canvas canvas, DropType type, Offset c, double r, double rot) { // gambar benda
  canvas.save(); // simpan kanvas
  canvas.translate(c.dx, c.dy); // pindah ke pusat benda
  canvas.rotate(rot); // putar benda
  switch (type) { // sesuai jenis
    case DropType.siwalan: // buah siwalan segar: ungu tua mengilap dengan mahkota daun
      canvas.drawCircle(Offset.zero, r, Paint()..shader = const RadialGradient(center: Alignment(-0.4, -0.4), colors: [Color(0xFF7B5A86), Color(0xFF3E2C41)]).createShader(Rect.fromCircle(center: Offset.zero, radius: r))); // badan buah
      canvas.drawCircle(Offset(-r * 0.35, -r * 0.35), r * 0.18, Paint()..color = Colors.white.withAlpha(120)); // kilap
      final leaf = Paint()..color = const Color(0xFF43A047)..style = PaintingStyle.stroke..strokeWidth = r * 0.14..strokeCap = StrokeCap.round; // kuas mahkota
      for (final a in [-0.8, 0.0, 0.8]) { canvas.drawLine(Offset(0, -r * 0.85), Offset(math.sin(a) * r * 0.55, -r * 1.25), leaf); } // tiga helai mahkota
      break;
    case DropType.emas: // buah emas berpendar
      canvas.drawCircle(Offset.zero, r * 1.5, Paint()..shader = RadialGradient(colors: [const Color(0xFFFFD54F).withAlpha(150), Colors.transparent]).createShader(Rect.fromCircle(center: Offset.zero, radius: r * 1.5))); // pendar
      canvas.drawCircle(Offset.zero, r, Paint()..shader = const RadialGradient(center: Alignment(-0.4, -0.4), colors: [Color(0xFFFFF176), Color(0xFFFFB300)]).createShader(Rect.fromCircle(center: Offset.zero, radius: r))); // badan emas
      canvas.drawCircle(Offset.zero, r, Paint()..color = const Color(0xFF8D5A00)..style = PaintingStyle.stroke..strokeWidth = 1.5); // garis tepi
      canvas.drawLine(Offset(0, -r * 0.5), Offset(0, r * 0.5), Paint()..color = Colors.white70..strokeWidth = 2); // kilau tegak
      canvas.drawLine(Offset(-r * 0.5, 0), Offset(r * 0.5, 0), Paint()..color = Colors.white70..strokeWidth = 2); // kilau datar
      break;
    case DropType.legen: // gelas legen
      final glass = Path()..moveTo(-r * 0.8, -r)..lineTo(r * 0.8, -r)..lineTo(r * 0.55, r)..lineTo(-r * 0.55, r)..close(); // bentuk gelas
      canvas.drawPath(glass, Paint()..color = const Color(0xFFFFB74D)); // isi legen
      canvas.drawRect(Rect.fromLTRB(-r * 0.8, -r, r * 0.8, -r * 0.55), Paint()..color = Colors.white.withAlpha(220)); // buih putih
      canvas.drawPath(glass, Paint()..color = Colors.white70..style = PaintingStyle.stroke..strokeWidth = 1.6); // tepi kaca
      break;
    case DropType.busuk: // buah busuk: abu kecokelatan, bintik, uap bau
      canvas.drawCircle(Offset.zero, r, Paint()..color = const Color(0xFF6D6254)); // badan buah
      final spot = Paint()..color = const Color(0xFF2F3A1F); // bintik jamur
      canvas.drawCircle(Offset(-r * 0.3, r * 0.1), r * 0.22, spot); // bintik 1
      canvas.drawCircle(Offset(r * 0.35, -r * 0.2), r * 0.16, spot); // bintik 2
      canvas.drawCircle(Offset(r * 0.1, r * 0.5), r * 0.14, spot); // bintik 3
      final wisp = Paint()..color = const Color(0xFF9CCC65)..style = PaintingStyle.stroke..strokeWidth = 1.6; // kuas uap
      canvas.drawPath(Path()..moveTo(-r * 0.4, -r * 1.1)..quadraticBezierTo(-r * 0.1, -r * 1.4, -r * 0.4, -r * 1.7), wisp); // uap kiri
      canvas.drawPath(Path()..moveTo(r * 0.4, -r * 1.1)..quadraticBezierTo(r * 0.7, -r * 1.4, r * 0.4, -r * 1.7), wisp); // uap kanan
      break;
  }
  canvas.restore(); // kembalikan kanvas
}

/// Menggambar keranjang anyaman rotan di pusat atas [top]. [bump] 0..1 membuatnya sedikit membal.
void _drawBasket(Canvas canvas, Offset top, double bump) { // gambar keranjang
  const w = _SiwalanGameScreenState._basketW; // lebar
  const h = _SiwalanGameScreenState._basketH; // tinggi
  final sy = 1 + 0.12 * bump; // pelebaran vertikal saat membal
  canvas.save(); // simpan kanvas
  canvas.translate(top.dx, top.dy + h); // titik tumpu di dasar keranjang
  canvas.scale(1 + 0.06 * bump, sy); // skala membal
  canvas.translate(-w / 2, -h); // geser ke sudut kiri atas keranjang
  final body = Path()..moveTo(0, 0)..lineTo(w, 0)..lineTo(w * 0.86, h)..lineTo(w * 0.14, h)..close(); // badan keranjang berbentuk trapesium
  canvas.drawPath(body, Paint()..shader = const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFD9A35B), Color(0xFF9C6B30)]).createShader(Rect.fromLTWH(0, 0, w, h))); // warna rotan
  canvas.save(); // simpan sebelum memotong
  canvas.clipPath(body); // anyaman hanya di dalam badan
  final weave = Paint()..color = const Color(0xFF6D4620).withAlpha(150)..strokeWidth = 1.4; // kuas anyaman
  for (double y = 8; y < h; y += 9) { canvas.drawLine(Offset(0, y), Offset(w, y), weave); } // garis anyaman mendatar
  for (double x = -h; x < w + h; x += 13) { canvas.drawLine(Offset(x, 0), Offset(x + h * 0.6, h), weave); } // anyaman miring ke kanan
  for (double x = 0; x < w + h; x += 13) { canvas.drawLine(Offset(x, 0), Offset(x - h * 0.6, h), weave); } // anyaman miring ke kiri
  canvas.restore(); // akhiri pemotongan
  canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(-4, -5, w + 8, 10), const Radius.circular(5)), Paint()..color = const Color(0xFF7A4E1F)); // bibir keranjang
  canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(-4, -5, w + 8, 10), const Radius.circular(5)), Paint()..color = const Color(0xFFEDAA3A)..style = PaintingStyle.stroke..strokeWidth = 1.5); // garis emas bibir
  canvas.restore(); // kembalikan kanvas
}
