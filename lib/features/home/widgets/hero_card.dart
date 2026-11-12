import 'dart:async'; // Timer untuk geser otomatis
import 'package:flutter/material.dart'; // widget dasar Flutter

import '../../../core/widgets/batik_pattern.dart'; // motif batik transparan
import '../../../core/widgets/tuban_scene.dart'; // ilustrasi tempat ikonik

class _Slide {
  final SceneKind kind; // pemandangan
  final String title; // judul tempat
  final String caption; // keterangan
  const _Slide(this.kind, this.title, this.caption); // konstruktor
}

const List<_Slide> _slides = [
  _Slide(SceneKind.pantai, 'Pantai Boom', 'Bekas pelabuhan lama di tepi laut Tuban'), // slide 1
  _Slide(SceneKind.gua, 'Gua Akbar', 'Lorong berstalaktit di tengah kota'), // slide 2
  _Slide(SceneKind.klenteng, 'Klenteng Kwan Sing Bio', 'Merah dan emas, tanda budaya yang hidup berdampingan'), // slide 3
  _Slide(SceneKind.makam, 'Jejak Bumi Wali', 'Makam Sunan Bonang dan kisah penyebar Islam'), // slide 4
  _Slide(SceneKind.tenun, 'Tenun Gedog', 'Kain biru nila bermotif tangan dari Kerek'), // slide 5
  _Slide(SceneKind.siwalan, 'Kebun Siwalan', 'Pohon lambang Tuban, sumber legen dan gula'), // slide 6
];

/// Hero Card: carousel ilustrasi tempat ikonik Tuban, bergeser otomatis dan menyesuaikan waktu sehari.
class HeroCard extends StatefulWidget {
  final VoidCallback onExplore; // dipanggil saat tombol Jelajahi ditekan
  const HeroCard({super.key, required this.onExplore}); // konstruktor

  @override
  State<HeroCard> createState() => _HeroCardState(); // buat state
}

class _HeroCardState extends State<HeroCard> {
  final PageController _page = PageController(); // pengendali halaman
  Timer? _auto; // pemicu geser otomatis
  int _current = 0; // halaman aktif

  /// Waktu sehari dari jam perangkat: 0 pagi, 1 siang, 2 senja, 3 malam.
  int get _phase { // tentukan waktu
    final h = DateTime.now().hour; // jam sekarang
    if (h >= 5 && h < 10) return 0; // pagi
    if (h >= 10 && h < 16) return 1; // siang
    if (h >= 16 && h < 19) return 2; // senja
    return 3; // malam
  }

  @override
  void initState() { // dipanggil sekali
    super.initState(); // panggil induk
    _auto = Timer.periodic(const Duration(seconds: 5), (_) { // tiap 5 detik
      if (!_page.hasClients) return; // belum siap
      final next = (_current + 1) % _slides.length; // halaman berikutnya (berputar)
      _page.animateToPage(next, duration: const Duration(milliseconds: 600), curve: Curves.easeInOut); // geser mulus
    });
  }

  @override
  void dispose() { // dipanggil saat widget dilepas
    _auto?.cancel(); // hentikan pemicu
    _page.dispose(); // bebaskan pengendali
    super.dispose(); // panggil induk
  }

  @override
  Widget build(BuildContext context) { // membangun kartu
    return ClipRRect(
      borderRadius: BorderRadius.circular(24), // sudut membulat
      child: SizedBox(
        height: 220, // tinggi kartu
        child: Stack(children: [
          PageView.builder( // halaman geser
            controller: _page, // pengendali
            itemCount: _slides.length, // jumlah slide
            onPageChanged: (i) => setState(() => _current = i), // catat halaman aktif
            itemBuilder: (_, i) => TubanScene(kind: _slides[i].kind, phase: _phase), // ilustrasi tiap slide
          ),
          const Positioned.fill(child: BatikOverlay(color: Color(0x18FFFFFF), cell: 44)), // aksen batik transparan di atas ilustrasi
          Positioned.fill(child: IgnorePointer(child: DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withAlpha(170)], stops: const [0.45, 1]))))), // bayangan bawah agar teks terbaca
          Positioned(left: 16, right: 16, bottom: 14, child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Expanded(child: AnimatedSwitcher( // teks berganti halus
              duration: const Duration(milliseconds: 350), // lama transisi
              child: Column(key: ValueKey(_current), crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(_slides[_current].title, style: const TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w900, shadows: [Shadow(blurRadius: 6, color: Colors.black54)])), // judul tempat
                const SizedBox(height: 2), // jarak
                Text(_slides[_current].caption, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70, fontSize: 12.5)), // keterangan
              ]),
            )),
            const SizedBox(width: 10), // jarak
            FilledButton(onPressed: widget.onExplore, style: FilledButton.styleFrom(backgroundColor: const Color(0xFFEDAA3A), foregroundColor: const Color(0xFF26376B)), child: const Text('Jelajahi')), // tombol menuju peta
          ])),
          Positioned(top: 12, right: 14, child: Row(children: [ // penunjuk halaman
            for (int i = 0; i < _slides.length; i++)
              AnimatedContainer(duration: const Duration(milliseconds: 250), margin: const EdgeInsets.only(left: 4), width: i == _current ? 18 : 6, height: 6, decoration: BoxDecoration(color: i == _current ? Colors.white : Colors.white54, borderRadius: BorderRadius.circular(3))), // titik penunjuk
          ])),
        ]),
      ),
    );
  }
}
