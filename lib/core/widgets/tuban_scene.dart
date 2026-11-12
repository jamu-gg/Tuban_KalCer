import 'dart:math' as math; // fungsi matematika (sin, cos, pi)
import 'package:flutter/material.dart'; // widget dasar Flutter

import 'batik_pattern.dart'; // motif kawung untuk kain tenun

/// Jenis pemandangan ikonik Tuban yang digambar sebagai ilustrasi vektor (tanpa berkas gambar).
enum SceneKind { pantai, klenteng, gua, makam, tenun, siwalan } // enam pemandangan

/// Widget ilustrasi pemandangan Tuban. [phase]: 0 pagi, 1 siang, 2 senja, 3 malam.
class TubanScene extends StatefulWidget {
  final SceneKind kind; // pemandangan yang digambar
  final int phase; // waktu dalam sehari
  final bool flip; // cerminkan gambar secara mendatar (untuk variasi galeri)
  const TubanScene({super.key, required this.kind, this.phase = 1, this.flip = false}); // konstruktor

  @override
  State<TubanScene> createState() => _TubanSceneState(); // buat state
}

class _TubanSceneState extends State<TubanScene> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 12))..repeat(); // putaran gerak halus (awan, ombak)

  @override
  void dispose() { // dipanggil saat widget dilepas
    _ctrl.dispose(); // hentikan animasi agar tidak bocor
    super.dispose(); // panggil induk
  }

  @override
  Widget build(BuildContext context) { // membangun widget
    return RepaintBoundary( // pisahkan penggambaran agar hemat tenaga
      child: Transform.flip( // cerminkan bila diminta
        flipX: widget.flip, // sumbu mendatar
        child: CustomPaint( // area gambar kustom
          painter: _ScenePainter(widget.kind, widget.phase, _ctrl), // pelukis pemandangan
          size: Size.infinite, // penuhi ruang induk
        ),
      ),
    );
  }
}

/// Palet langit untuk tiap waktu: [atas, bawah].
const List<List<Color>> _skies = [ // daftar palet
  [Color(0xFFFFD9A0), Color(0xFFBFE3F5)], // pagi
  [Color(0xFF6EC1E8), Color(0xFFDDF1FA)], // siang
  [Color(0xFF3B3F7A), Color(0xFFFF9E6B)], // senja
  [Color(0xFF0B1230), Color(0xFF26376B)], // malam
];

class _ScenePainter extends CustomPainter {
  final SceneKind kind; // jenis pemandangan
  final int phase; // waktu dalam sehari
  final AnimationController ctrl; // pengendali gerak
  _ScenePainter(this.kind, this.phase, this.ctrl) : super(repaint: ctrl); // gambar ulang tiap animasi berdetak

  double get _t => ctrl.value; // nilai gerak 0..1

  @override
  void paint(Canvas canvas, Size size) { // menggambar seluruh adegan
    final w = size.width; // lebar area
    final h = size.height; // tinggi area
    final indoor = kind == SceneKind.gua || kind == SceneKind.tenun; // adegan dalam ruangan tidak berlangit
    if (!indoor) { // adegan luar ruangan: gambar langit, matahari/bulan, awan
      canvas.drawRect(Rect.fromLTWH(0, 0, w, h), Paint()..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: _skies[phase]).createShader(Rect.fromLTWH(0, 0, w, h))); // gradasi langit
      _sunMoon(canvas, w, h); // benda langit
      _clouds(canvas, w, h); // awan bergerak
    }
    switch (kind) { // gambar bagian depan sesuai pemandangan
      case SceneKind.pantai: _pantai(canvas, w, h); break; // pantai
      case SceneKind.klenteng: _klenteng(canvas, w, h); break; // klenteng
      case SceneKind.gua: _gua(canvas, w, h); break; // gua
      case SceneKind.makam: _makam(canvas, w, h); break; // masjid/makam
      case SceneKind.tenun: _tenun(canvas, w, h); break; // tenun
      case SceneKind.siwalan: _siwalan(canvas, w, h); break; // kebun siwalan
    }
  }

  void _sunMoon(Canvas c, double w, double h) { // matahari atau bulan
    final night = phase == 3; // malam?
    final pos = switch (phase) { 0 => Offset(w * 0.22, h * 0.30), 1 => Offset(w * 0.75, h * 0.18), 2 => Offset(w * 0.78, h * 0.46), _ => Offset(w * 0.8, h * 0.2) }; // posisi benda langit
    final color = night ? const Color(0xFFF5F1D0) : (phase == 2 ? const Color(0xFFFF7043) : const Color(0xFFFFE082)); // warna benda langit
    c.drawCircle(pos, h * 0.13, Paint()..color = color.withAlpha(60)); // lingkaran cahaya luar
    c.drawCircle(pos, h * 0.075, Paint()..color = color); // lingkaran inti
    if (night) { // bintang kecil saat malam
      final p = Paint()..color = Colors.white70; // kuas bintang
      for (int i = 0; i < 18; i++) { // 18 bintang
        c.drawCircle(Offset((i * 83 % 100) / 100 * w, (i * 37 % 45) / 100 * h), 1.2, p); // sebar bintang secara tetap
      }
    }
  }

  void _clouds(Canvas c, double w, double h) { // awan melayang pelan
    if (phase == 3) return; // malam tanpa awan
    final p = Paint()..color = Colors.white.withAlpha(phase == 2 ? 110 : 190); // warna awan
    for (int i = 0; i < 3; i++) { // tiga awan
      final x = ((_t + i / 3) % 1.0) * (w + 120) - 60; // posisi mendatar bergeser
      final y = h * (0.12 + 0.1 * i); // tinggi awan
      c.drawOval(Rect.fromCenter(center: Offset(x, y), width: 70, height: 20), p); // badan awan
      c.drawOval(Rect.fromCenter(center: Offset(x + 18, y - 8), width: 40, height: 18), p); // gumpalan atas
    }
  }

  /// Menggambar pohon siwalan: batang melengkung, pelepah kipas, dan buah.
  void _palm(Canvas c, Offset base, double h, {double lean = 0, Color? leaf}) { // pohon
    final top = base + Offset(lean, -h); // pucuk pohon
    final trunk = Paint()..color = const Color(0xFF5D4037)..style = PaintingStyle.stroke..strokeWidth = h * 0.06..strokeCap = StrokeCap.round; // kuas batang
    c.drawPath(Path()..moveTo(base.dx, base.dy)..quadraticBezierTo(base.dx + lean * 0.1, base.dy - h * 0.55, top.dx, top.dy), trunk); // batang melengkung
    final lp = Paint()..color = leaf ?? const Color(0xFF2E7D32)..style = PaintingStyle.stroke..strokeWidth = h * 0.05..strokeCap = StrokeCap.round; // kuas pelepah
    for (final a in const [-175, -145, -115, -80, -50, -15]) { // enam pelepah menyebar
      final r = a * math.pi / 180; // ubah derajat ke radian
      final dir = Offset(math.cos(r), math.sin(r)); // arah pelepah
      final mid = top + dir * h * 0.22 + Offset(0, -h * 0.08); // titik lengkung
      final end = top + dir * h * 0.40 + Offset(0, h * 0.10); // ujung pelepah terkulai
      c.drawPath(Path()..moveTo(top.dx, top.dy)..quadraticBezierTo(mid.dx, mid.dy, end.dx, end.dy), lp); // gambar pelepah
    }
    final fruit = Paint()..color = const Color(0xFF3E2C41); // warna buah
    c.drawCircle(top + Offset(-h * 0.04, h * 0.05), h * 0.03, fruit); // buah kiri
    c.drawCircle(top + Offset(h * 0.04, h * 0.06), h * 0.03, fruit); // buah kanan
  }

  void _pantai(Canvas c, double w, double h) { // pantai dan kapal bandar
    final horizon = h * 0.56; // garis cakrawala
    c.drawRect(Rect.fromLTWH(0, horizon, w, h * 0.30), Paint()..shader = const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF1E88C7), Color(0xFF4FC3F7)]).createShader(Rect.fromLTWH(0, horizon, w, h * 0.30))); // laut
    final wave = Paint()..color = Colors.white.withAlpha(120)..style = PaintingStyle.stroke..strokeWidth = 1.6; // kuas ombak
    for (int r = 0; r < 4; r++) { // empat baris ombak
      final path = Path(); // jalur ombak
      final y = horizon + h * (0.04 + r * 0.06); // tinggi baris
      path.moveTo(0, y); // mulai dari kiri
      for (double x = 0; x <= w; x += 6) { // telusuri ke kanan
        path.lineTo(x, y + math.sin((x / w * 6 * math.pi) + _t * 2 * math.pi + r) * 2.4); // gelombang sinus bergerak
      }
      c.drawPath(path, wave); // gambar baris ombak
    }
    c.drawPath(Path()..moveTo(0, h * 0.84)..quadraticBezierTo(w * 0.5, h * 0.78, w, h * 0.86)..lineTo(w, h)..lineTo(0, h)..close(), Paint()..color = const Color(0xFFF1D9A5)); // hamparan pasir
    final sx = w * (0.55 + 0.04 * math.sin(_t * 2 * math.pi)); // kapal terombang-ambing
    final sy = horizon + h * 0.05; // tinggi kapal
    c.drawPath(Path()..moveTo(sx - 26, sy)..lineTo(sx + 26, sy)..lineTo(sx + 16, sy + 12)..lineTo(sx - 16, sy + 12)..close(), Paint()..color = const Color(0xFF5D4037)); // lambung kapal
    c.drawLine(Offset(sx, sy), Offset(sx, sy - 34), Paint()..color = const Color(0xFF3E2723)..strokeWidth = 2); // tiang layar
    c.drawPath(Path()..moveTo(sx, sy - 34)..lineTo(sx + 22, sy - 6)..lineTo(sx, sy - 6)..close(), Paint()..color = Colors.white); // layar putih
    _palm(c, Offset(w * 0.14, h * 0.90), h * 0.50, lean: 18); // pohon kiri
    _palm(c, Offset(w * 0.90, h * 0.92), h * 0.38, lean: -14); // pohon kanan
  }

  void _klenteng(Canvas c, double w, double h) { // klenteng merah
    c.drawRect(Rect.fromLTWH(0, h * 0.78, w, h * 0.22), Paint()..color = const Color(0xFF6D8F5A)); // halaman rumput
    final bx = w * 0.22; // tepi kiri bangunan
    final bw = w * 0.56; // lebar bangunan
    c.drawRect(Rect.fromLTWH(bx, h * 0.52, bw, h * 0.27), Paint()..color = const Color(0xFFB8402F)); // dinding merah
    c.drawRect(Rect.fromLTWH(w * 0.45, h * 0.62, w * 0.10, h * 0.17), Paint()..color = const Color(0xFF5D1F17)); // pintu
    for (final k in [0, 1]) { // dua tingkat atap
      final top = h * (0.40 - k * 0.13); // tinggi atap
      final half = bw * (0.62 - k * 0.20); // setengah lebar atap
      c.drawPath(Path()..moveTo(w / 2 - half, top + h * 0.08)..quadraticBezierTo(w / 2 - half * 0.7, top + h * 0.09, w / 2 - half * 0.55, top)..lineTo(w / 2 + half * 0.55, top)..quadraticBezierTo(w / 2 + half * 0.7, top + h * 0.09, w / 2 + half, top + h * 0.08)..lineTo(w / 2 + half * 0.7, top + h * 0.11)..lineTo(w / 2 - half * 0.7, top + h * 0.11)..close(), Paint()..color = k == 0 ? const Color(0xFF8E2F23) : const Color(0xFFEDAA3A)); // atap berujung melengkung
    }
    for (final dx in [0.30, 0.70]) { // dua lampion
      c.drawLine(Offset(w * dx, h * 0.52), Offset(w * dx, h * 0.58), Paint()..color = Colors.black54); // tali lampion
      c.drawOval(Rect.fromCenter(center: Offset(w * dx, h * 0.62), width: 18, height: 24), Paint()..color = const Color(0xFFE53935)); // badan lampion
      c.drawOval(Rect.fromCenter(center: Offset(w * dx, h * 0.62), width: 18, height: 24), Paint()..color = const Color(0xFFFFD54F)..style = PaintingStyle.stroke); // bingkai emas lampion
    }
  }

  void _gua(Canvas c, double w, double h) { // gua berstalaktit
    c.drawRect(Rect.fromLTWH(0, 0, w, h), Paint()..shader = const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF1B1F2A), Color(0xFF3B3350)]).createShader(Rect.fromLTWH(0, 0, w, h))); // dinding gua gelap
    c.drawCircle(Offset(w * 0.5, h * 0.55), h * 0.5, Paint()..shader = RadialGradient(colors: [const Color(0xFFB388FF).withAlpha(120), Colors.transparent]).createShader(Rect.fromCircle(center: Offset(w * 0.5, h * 0.55), radius: h * 0.5))); // pendar ungu
    c.drawPath(Path()..moveTo(w * 0.42, 0)..lineTo(w * 0.58, 0)..lineTo(w * 0.72, h)..lineTo(w * 0.28, h)..close(), Paint()..color = Colors.white.withAlpha(22 + (14 * math.sin(_t * 2 * math.pi)).round())); // berkas cahaya dari lubang atas
    final stal = Paint()..color = const Color(0xFF6B5B7B); // warna batuan
    for (int i = 0; i < 9; i++) { // stalaktit di langit-langit
      final x = w * (i + 0.5) / 9; // posisi
      final len = h * (0.14 + 0.16 * ((i * 53) % 7) / 7); // panjang bervariasi tetap
      c.drawPath(Path()..moveTo(x - w * 0.04, 0)..lineTo(x, len)..lineTo(x + w * 0.04, 0)..close(), stal); // segitiga runcing
    }
    for (int i = 0; i < 7; i++) { // stalagmit di lantai
      final x = w * (i + 0.7) / 7.4; // posisi
      final len = h * (0.10 + 0.12 * ((i * 37) % 5) / 5); // tinggi bervariasi tetap
      c.drawPath(Path()..moveTo(x - w * 0.04, h)..lineTo(x, h - len)..lineTo(x + w * 0.04, h)..close(), Paint()..color = const Color(0xFF4A3F5C)); // segitiga naik
    }
  }

  void _makam(Canvas c, double w, double h) { // masjid dan kubah
    c.drawRect(Rect.fromLTWH(0, h * 0.80, w, h * 0.20), Paint()..color = const Color(0xFF5E8F5A)); // halaman
    c.drawRect(Rect.fromLTWH(w * 0.28, h * 0.52, w * 0.44, h * 0.28), Paint()..color = const Color(0xFFF4EBD0)); // badan bangunan
    c.drawArc(Rect.fromLTWH(w * 0.36, h * 0.32, w * 0.28, h * 0.40), math.pi, math.pi, true, Paint()..color = const Color(0xFF1F7A4F)); // kubah hijau
    c.drawRect(Rect.fromLTWH(w * 0.495, h * 0.22, w * 0.01, h * 0.12), Paint()..color = const Color(0xFFEDAA3A)); // tiang puncak
    for (final x in [0.20, 0.80]) { // dua menara
      c.drawRect(Rect.fromLTWH(w * x - w * 0.025, h * 0.34, w * 0.05, h * 0.46), Paint()..color = const Color(0xFFE8DDB8)); // badan menara
      c.drawPath(Path()..moveTo(w * x - w * 0.035, h * 0.34)..lineTo(w * x, h * 0.25)..lineTo(w * x + w * 0.035, h * 0.34)..close(), Paint()..color = const Color(0xFF1F7A4F)); // atap menara
    }
    for (final x in [0.06, 0.94]) { // pohon di tepi
      c.drawCircle(Offset(w * x, h * 0.70), h * 0.14, Paint()..color = const Color(0xFF2E6B3A)); // tajuk pohon
    }
    c.drawRect(Rect.fromLTWH(w * 0.46, h * 0.64, w * 0.08, h * 0.16), Paint()..color = const Color(0xFF8D6E4A)); // pintu kayu
  }

  void _tenun(Canvas c, double w, double h) { // alat tenun dan kain gedog
    c.drawRect(Rect.fromLTWH(0, 0, w, h), Paint()..shader = const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF1B2A55), Color(0xFF26376B)]).createShader(Rect.fromLTWH(0, 0, w, h))); // latar biru nila
    final wood = Paint()..color = const Color(0xFF8D6E4A); // warna kayu
    c.drawRect(Rect.fromLTWH(w * 0.10, h * 0.12, w * 0.04, h * 0.80), wood); // tiang kiri
    c.drawRect(Rect.fromLTWH(w * 0.86, h * 0.12, w * 0.04, h * 0.80), wood); // tiang kanan
    c.drawRect(Rect.fromLTWH(w * 0.08, h * 0.10, w * 0.84, h * 0.05), wood); // palang atas
    final thread = Paint()..color = Colors.white.withAlpha(150)..strokeWidth = 1; // benang lungsin
    for (int i = 0; i < 26; i++) { // benang vertikal
      final x = w * (0.16 + i * 0.68 / 25); // posisi benang
      c.drawLine(Offset(x, h * 0.15), Offset(x, h * 0.50), thread); // satu benang
    }
    final cloth = Rect.fromLTWH(w * 0.16, h * 0.50, w * 0.68, h * 0.34); // area kain jadi
    c.drawRect(cloth, Paint()..shader = const LinearGradient(colors: [Color(0xFF3A4FA0), Color(0xFF26376B)]).createShader(cloth)); // kain biru
    c.save(); // simpan kanvas
    c.clipRect(cloth); // batasi motif pada kain
    c.translate(cloth.left, cloth.top); // geser ke sudut kain
    BatikKawungPainter(color: const Color(0xFFEDAA3A), cell: 30).paint(c, cloth.size); // motif kawung emas
    c.restore(); // kembalikan kanvas
    final shuttleX = w * (0.2 + 0.6 * (0.5 + 0.5 * math.sin(_t * 2 * math.pi))); // posisi teropong bergerak
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(shuttleX, h * 0.50), width: 40, height: 9), const Radius.circular(5)), Paint()..color = const Color(0xFFEDAA3A)); // teropong tenun emas
  }

  void _siwalan(Canvas c, double w, double h) { // kebun siwalan di savana
    c.drawRect(Rect.fromLTWH(0, h * 0.70, w, h * 0.30), Paint()..shader = const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFB7C46B), Color(0xFF6E8F3F)]).createShader(Rect.fromLTWH(0, h * 0.70, w, h * 0.30))); // tanah lapang
    c.drawPath(Path()..moveTo(0, h * 0.72)..quadraticBezierTo(w * 0.3, h * 0.62, w * 0.6, h * 0.72)..quadraticBezierTo(w * 0.8, h * 0.66, w, h * 0.72)..lineTo(w, h * 0.74)..lineTo(0, h * 0.74)..close(), Paint()..color = const Color(0xFF4E7A3A)); // bukit rendah di kejauhan
    _palm(c, Offset(w * 0.15, h * 0.90), h * 0.62, lean: 14); // pohon 1
    _palm(c, Offset(w * 0.38, h * 0.82), h * 0.46, lean: -10); // pohon 2
    _palm(c, Offset(w * 0.64, h * 0.88), h * 0.58, lean: 10); // pohon 3
    _palm(c, Offset(w * 0.86, h * 0.80), h * 0.40, lean: -12); // pohon 4
  }

  @override
  bool shouldRepaint(_ScenePainter old) => old.kind != kind || old.phase != phase; // gambar ulang bila adegan berubah (gerak sudah ditangani repaint)
}
