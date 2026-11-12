import 'dart:math' as math; // sin untuk lengkung koin
import 'package:flutter/material.dart'; // widget dasar Flutter

import '../../../core/theme/app_theme.dart'; // warna aplikasi
import '../../../core/widgets/batik_pattern.dart'; // aksen batik
import '../../../core/widgets/tuban_scene.dart'; // ilustrasi galeri
import '../controllers/narration_controller.dart'; // narasi
import '../data/poi_data.dart'; // data lokasi

/// Story Card: galeri ilustrasi, tombol narasi, teks bersorot, dan misi baca dengan animasi koin terbang.
/// Menutup dengan nilai true bila misi selesai dan hadiah diklaim.
class StoryCard extends StatefulWidget {
  final Poi poi; // lokasi yang ditampilkan
  final bool alreadyClaimed; // hadiah lokasi ini sudah pernah diambil?
  const StoryCard({super.key, required this.poi, required this.alreadyClaimed}); // konstruktor

  @override
  State<StoryCard> createState() => _StoryCardState(); // buat state
}

class _StoryCardState extends State<StoryCard> with SingleTickerProviderStateMixin {
  final ScrollController _scroll = ScrollController(); // pengendali gulir teks
  final PageController _gallery = PageController(); // pengendali galeri
  final GlobalKey _stackKey = GlobalKey(); // acuan koordinat lapisan terbang
  final GlobalKey _chipKey = GlobalKey(); // lencana koin (tujuan koin terbang)
  final GlobalKey _btnKey = GlobalKey(); // tombol klaim (asal koin terbang)
  late final List<GlobalKey> _paraKeys; // kunci tiap paragraf untuk gulir otomatis
  late final NarrationController _narr; // narasi
  late final AnimationController _fly; // animasi koin terbang
  int _shot = 0; // foto galeri aktif
  double _scrollFrac = 0; // kemajuan gulir 0..1
  bool _claiming = false; // sedang animasi klaim?
  Offset _from = Offset.zero, _to = Offset.zero; // lintasan koin terbang
  int _lastNarrIndex = -1; // paragraf narasi terakhir yang sudah digulirkan

  @override
  void initState() { // dipanggil sekali
    super.initState(); // panggil induk
    _paraKeys = List.generate(widget.poi.paragraphs.length, (_) => GlobalKey()); // satu kunci per paragraf
    _narr = NarrationController(widget.poi.paragraphs)..addListener(_onNarration); // pantau narasi
    _fly = AnimationController(vsync: this, duration: const Duration(milliseconds: 1300)) // animasi koin
      ..addStatusListener((s) { if (s == AnimationStatus.completed && mounted) Navigator.pop(context, true); }); // tutup kartu setelah koin tiba
    _scroll.addListener(_onScroll); // pantau gulir
    WidgetsBinding.instance.addPostFrameCallback((_) => _onScroll()); // cek juga saat teks pendek
  }

  @override
  void dispose() { // dipanggil saat kartu ditutup
    _narr.removeListener(_onNarration); // lepas pemantau
    _narr.dispose(); _fly.dispose(); _scroll.dispose(); _gallery.dispose(); // bebaskan semua pengendali
    super.dispose(); // panggil induk
  }

  void _onScroll() { // hitung kemajuan gulir
    if (!_scroll.hasClients) return; // belum siap
    final max = _scroll.position.maxScrollExtent; // gulir maksimum
    final f = max <= 0 ? 1.0 : (_scroll.position.pixels / max).clamp(0.0, 1.0).toDouble(); // 1 bila tidak perlu digulir
    if ((f - _scrollFrac).abs() > 0.005 || f == 1.0) setState(() => _scrollFrac = math.max(_scrollFrac, f)); // simpan kemajuan terbesar
  }

  void _onNarration() { // narasi berjalan: gulir ke paragraf yang dibacakan
    if (!mounted) return; // pastikan masih ada
    if (_narr.index != _lastNarrIndex && _narr.playing) { // paragraf baru
      _lastNarrIndex = _narr.index; // catat
      final ctx = _paraKeys[_narr.index].currentContext; // konteks paragraf
      if (ctx != null) Scrollable.ensureVisible(ctx, duration: const Duration(milliseconds: 450), alignment: 0.2, curve: Curves.easeInOut); // gulir mulus
    }
    setState(() {}); // perbarui tampilan
  }

  /// Kemajuan misi: gabungan gulir dan narasi, mana yang lebih jauh.
  double get _progress => math.max(_scrollFrac, _narr.overall); // 0..1
  bool get _missionDone => _progress >= 0.999 || _narr.finished; // misi selesai?

  /// Mulai animasi koin terbang dari tombol ke lencana koin di kepala.
  void _claim() { // klaim hadiah
    final stack = _stackKey.currentContext?.findRenderObject() as RenderBox?; // lapisan acuan
    final btn = _btnKey.currentContext?.findRenderObject() as RenderBox?; // tombol
    final chip = _chipKey.currentContext?.findRenderObject() as RenderBox?; // lencana koin
    if (stack == null || btn == null || chip == null) { Navigator.pop(context, true); return; } // cadangan bila ukuran belum ada
    _from = stack.globalToLocal(btn.localToGlobal(btn.size.center(Offset.zero))); // asal
    _to = stack.globalToLocal(chip.localToGlobal(chip.size.center(Offset.zero))); // tujuan
    _narr.pause(); // hentikan narasi
    setState(() => _claiming = true); // tampilkan lapisan koin
    _fly.forward(from: 0); // putar animasi
  }

  @override
  Widget build(BuildContext context) { // membangun kartu
    final p = widget.poi; // singkatan
    final screenH = MediaQuery.of(context).size.height; // tinggi layar
    return SizedBox(
      height: screenH * 0.92, // kartu hampir setinggi layar
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)), // sudut atas membulat
        child: Container(
          color: AppColors.cream, // latar krem
          child: Stack(key: _stackKey, children: [
            Column(children: [
              _galleryHeader(p), // galeri dengan lencana koin
              Padding(padding: const EdgeInsets.fromLTRB(18, 14, 18, 6), child: Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(p.name, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900, color: AppColors.greenDark)), // nama
                  Text(p.subtitle, style: const TextStyle(color: AppColors.indigo, fontSize: 12.5)), // keterangan
                ])),
                FilledButton.tonalIcon( // tombol narasi
                  onPressed: _claiming ? null : () => _narr.playing ? _narr.pause() : _narr.play(), // putar/jeda
                  icon: Icon(_narr.playing ? Icons.pause : (_narr.finished ? Icons.replay : Icons.volume_up)), // ikon sesuai keadaan
                  label: Text(_narr.playing ? 'Jeda' : (_narr.finished ? 'Ulang' : 'Dengarkan')), // teks sesuai keadaan
                ),
              ])),
              if (_narr.playing) Padding(padding: const EdgeInsets.symmetric(horizontal: 18), child: ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: _narr.paragraphProgress, minHeight: 3, color: AppColors.gold, backgroundColor: Colors.black12))), // bilah kemajuan paragraf
              Expanded(child: SingleChildScrollView(
                controller: _scroll, // pengendali gulir
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 16), // jarak dalam
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  for (int i = 0; i < p.paragraphs.length; i++)
                    AnimatedContainer( // paragraf yang dibacakan menyala
                      key: _paraKeys[i], // kunci untuk gulir otomatis
                      duration: const Duration(milliseconds: 300), // lama perubahan
                      margin: const EdgeInsets.only(bottom: 10), // jarak antar paragraf
                      padding: const EdgeInsets.all(10), // jarak dalam
                      decoration: BoxDecoration(
                        color: (_narr.playing && _narr.index == i) ? AppColors.gold.withAlpha(60) : Colors.transparent, // sorot paragraf aktif
                        borderRadius: BorderRadius.circular(12), // sudut membulat
                        border: Border(left: BorderSide(color: (_narr.playing && _narr.index == i) ? AppColors.gold : Colors.transparent, width: 3)), // garis emas di kiri
                      ),
                      child: Text(p.paragraphs[i], style: const TextStyle(fontSize: 15.5, height: 1.6)), // isi paragraf
                    ),
                ]),
              )),
              _missionBar(p), // panel misi
            ]),
            if (_claiming) _flyingCoins(), // koin terbang
          ]),
        ),
      ),
    );
  }

  /// Galeri ilustrasi geser dengan keterangan, penunjuk halaman, tombol tutup, dan lencana koin misi.
  Widget _galleryHeader(Poi p) { // kepala galeri
    return SizedBox(height: 200, child: Stack(children: [
      PageView.builder(
        controller: _gallery, // pengendali
        itemCount: p.gallery.length, // jumlah foto
        onPageChanged: (i) => setState(() => _shot = i), // catat foto aktif
        itemBuilder: (_, i) => TubanScene(kind: p.gallery[i].kind, phase: p.gallery[i].phase, flip: p.gallery[i].flip), // ilustrasi tiap foto
      ),
      const Positioned.fill(child: BatikOverlay(color: Color(0x14FFFFFF), cell: 40)), // aksen batik
      Positioned.fill(child: IgnorePointer(child: DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black26, Colors.transparent, Colors.black.withAlpha(150)], stops: const [0, 0.4, 1]))))), // bayangan atas dan bawah
      Positioned(top: 10, left: 10, child: Material(color: Colors.black38, shape: const CircleBorder(), child: IconButton(onPressed: _claiming ? null : () => Navigator.pop(context, false), icon: const Icon(Icons.close, color: Colors.white)))), // tombol tutup
      Positioned(top: 14, right: 14, child: Container(
        key: _chipKey, // tujuan koin terbang
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), // jarak dalam
        decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(20)), // lencana emas
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.monetization_on, size: 16, color: AppColors.indigo), // ikon koin
          const SizedBox(width: 4), // jarak
          Text(widget.alreadyClaimed ? 'Selesai' : '+${p.reward}', style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.indigo)), // jumlah hadiah
        ]),
      )),
      Positioned(left: 16, right: 16, bottom: 10, child: Row(children: [
        Expanded(child: Text(p.gallery[_shot].caption, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, shadows: [Shadow(blurRadius: 4, color: Colors.black54)]))), // keterangan foto
        for (int i = 0; i < p.gallery.length; i++) // titik penunjuk
          Container(margin: const EdgeInsets.only(left: 4), width: i == _shot ? 16 : 6, height: 6, decoration: BoxDecoration(color: i == _shot ? Colors.white : Colors.white54, borderRadius: BorderRadius.circular(3))),
      ])),
    ]));
  }

  /// Panel misi di bawah: kemajuan baca dan tombol klaim.
  Widget _missionBar(Poi p) { // panel misi
    final done = _missionDone; // selesai?
    return Container(
      padding: EdgeInsets.fromLTRB(18, 12, 18, 14 + MediaQuery.of(context).padding.bottom), // jarak dalam
      decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black12)]), // panel putih bergaris bayangan
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        if (!widget.alreadyClaimed) ...[
          Row(children: [
            Icon(done ? Icons.check_circle : Icons.menu_book, size: 18, color: done ? AppColors.green : AppColors.indigo), // ikon misi
            const SizedBox(width: 6), // jarak
            Expanded(child: Text(done ? 'Misi selesai!' : 'Misi: baca atau dengarkan sampai habis', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13))), // teks misi
            Text('${(_progress * 100).round()}%', style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.indigo)), // persen
          ]),
          const SizedBox(height: 6), // jarak
          ClipRRect(borderRadius: BorderRadius.circular(6), child: LinearProgressIndicator(value: _progress, minHeight: 8, color: done ? AppColors.green : AppColors.gold, backgroundColor: Colors.black12)), // bilah misi
          const SizedBox(height: 10), // jarak
        ],
        SizedBox(width: double.infinity, child: FilledButton(
          key: _btnKey, // asal koin terbang
          onPressed: _claiming ? null : (widget.alreadyClaimed ? () => Navigator.pop(context, false) : (done ? _claim : null)), // aktif sesuai keadaan
          child: Text(widget.alreadyClaimed ? 'Tutup' : (done ? 'Ambil hadiah +${p.reward} koin' : 'Baca sampai selesai')), // teks tombol
        )),
      ]),
    );
  }

  /// Lapisan koin yang melengkung terbang dari tombol ke lencana koin.
  Widget _flyingCoins() { // koin terbang
    return Positioned.fill(child: IgnorePointer(child: AnimatedBuilder(
      animation: _fly, // ikuti animasi
      builder: (_, __) => Stack(children: [
        for (int i = 0; i < 8; i++) // delapan koin bergiliran
          Builder(builder: (_) {
            final t = ((_fly.value - i * 0.06) / 0.62).clamp(0.0, 1.0).toDouble(); // kemajuan koin ke-i
            final e = Curves.easeInOut.transform(t); // kehalusan gerak
            final pos = Offset.lerp(_from, _to, e)! + Offset((i - 3.5) * 6 * math.sin(math.pi * t), -70 * math.sin(math.pi * t)); // lintasan melengkung ke atas
            return Positioned(left: pos.dx - 12, top: pos.dy - 12, child: Opacity(
              opacity: t <= 0 ? 0 : (1 - math.max(0, t - 0.85) / 0.15).clamp(0.0, 1.0).toDouble(), // muncul lalu hilang di tujuan
              child: Transform.scale(scale: 1.1 - 0.5 * t, child: const CircleAvatar(radius: 12, backgroundColor: AppColors.gold, child: Text('K', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.indigo)))), // koin kecil
            ));
          }),
      ]),
    )));
  }
}
