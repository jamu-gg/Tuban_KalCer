import 'dart:math' as math; // pi untuk ukiran spiral
import 'package:flutter/material.dart'; // widget dasar Flutter

import '../../../core/widgets/batik_pattern.dart'; // motif batik halus

/// Bingkai "ukiran kayu jati" bergaya ornamen Jawa untuk kartu pertanyaan kuis.
class CarvedFrame extends StatelessWidget {
  final Widget child; // isi bingkai
  final EdgeInsets padding; // jarak isi dari bingkai
  const CarvedFrame({super.key, required this.child, this.padding = const EdgeInsets.fromLTRB(26, 26, 26, 26)}); // konstruktor

  @override
  Widget build(BuildContext context) { // membangun bingkai
    return CustomPaint( // lukis ukiran di belakang isi
      painter: _CarvedPainter(), // pelukis ukiran
      child: Container(
        padding: padding, // jarak isi
        child: child, // isi (teks pertanyaan)
      ),
    );
  }
}

class _CarvedPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) { // menggambar bingkai
    final outer = RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(18)); // bentuk luar
    canvas.drawRRect(outer, Paint()..shader = const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF6B4423), Color(0xFF3E2410)]).createShader(Offset.zero & size)); // kayu jati gelap
    final inner = RRect.fromRectAndRadius(Rect.fromLTWH(12, 12, size.width - 24, size.height - 24), const Radius.circular(10)); // bidang dalam krem
    canvas.drawRRect(inner, Paint()..color = const Color(0xFFFBF4E2)); // kertas lontar krem
    canvas.save(); // simpan kanvas
    canvas.clipRRect(inner); // batasi motif di bidang dalam
    canvas.translate(12, 12); // geser ke sudut bidang dalam
    BatikKawungPainter(color: const Color(0x14B8402F), cell: 40).paint(canvas, Size(size.width - 24, size.height - 24)); // motif kawung sangat tipis
    canvas.restore(); // kembalikan kanvas
    final gold = Paint()..color = const Color(0xFFEDAA3A)..style = PaintingStyle.stroke..strokeWidth = 1.6; // garis emas ukiran
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(5, 5, size.width - 10, size.height - 10), const Radius.circular(14)), gold); // garis emas luar
    canvas.drawRRect(inner, gold..strokeWidth = 1.2); // garis emas dalam
    final w = size.width, h = size.height; // singkatan ukuran
    _corner(canvas, const Offset(12, 12), 0, gold); // sudut kiri atas
    _corner(canvas, Offset(w - 12, 12), math.pi / 2, gold); // sudut kanan atas
    _corner(canvas, Offset(w - 12, h - 12), math.pi, gold); // sudut kanan bawah
    _corner(canvas, Offset(12, h - 12), 3 * math.pi / 2, gold); // sudut kiri bawah
    for (final p in [Offset(w / 2, 6), Offset(w / 2, h - 6), Offset(6, h / 2), Offset(w - 6, h / 2)]) { // empat ornamen belah ketupat di tengah sisi
      canvas.drawPath(Path()..moveTo(p.dx, p.dy - 5)..lineTo(p.dx + 5, p.dy)..lineTo(p.dx, p.dy + 5)..lineTo(p.dx - 5, p.dy)..close(), Paint()..color = const Color(0xFFEDAA3A)); // belah ketupat emas
    }
  }

  /// Ukiran spiral (sulur) di satu sudut, diputar sesuai sudutnya.
  void _corner(Canvas c, Offset at, double rot, Paint paint) { // gambar sudut
    c.save(); // simpan kanvas
    c.translate(at.dx, at.dy); // pindah ke sudut
    c.rotate(rot); // putar sesuai sudut
    final path = Path()..moveTo(4, 26)..cubicTo(4, 10, 10, 4, 26, 4); // sulur utama melengkung
    c.drawPath(path, paint); // gambar sulur
    c.drawPath(Path()..moveTo(10, 20)..cubicTo(10, 14, 14, 10, 20, 10)..cubicTo(24, 10, 24, 16, 19, 16), paint); // gulungan kecil
    c.drawCircle(const Offset(8, 8), 2.2, Paint()..color = const Color(0xFFB8402F)); // titik merah di sudut
    c.restore(); // kembalikan kanvas
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false; // statis
}

/// Teks "+N" yang naik lalu memudar; ganti [token] untuk memutarnya lagi.
class FloatingGain extends StatelessWidget {
  final int token; // berubah tiap kali efek harus diputar ulang
  final String text; // isi teks
  final Color color; // warna teks
  const FloatingGain({super.key, required this.token, required this.text, this.color = const Color(0xFFEDAA3A)}); // konstruktor

  @override
  Widget build(BuildContext context) { // membangun efek
    if (token == 0) return const SizedBox.shrink(); // belum ada efek
    return TweenAnimationBuilder<double>( // animasi 0 ke 1
      key: ValueKey(token), // kunci baru memulai animasi dari awal
      tween: Tween(begin: 0, end: 1), // rentang nilai
      duration: const Duration(milliseconds: 1000), // lama animasi
      builder: (_, t, __) => Opacity( // memudar di akhir
        opacity: (1 - t).clamp(0.0, 1.0).toDouble(), // makin transparan
        child: Transform.translate( // naik ke atas
          offset: Offset(0, -60 * Curves.easeOut.transform(t)), // jarak naik
          child: Transform.scale(scale: 0.8 + 0.5 * math.sin(t * math.pi), child: Text(text, style: TextStyle(color: color, fontSize: 28, fontWeight: FontWeight.w900, shadows: const [Shadow(blurRadius: 6, color: Colors.black54)]))), // teks membesar sebentar
        ),
      ),
    );
  }
}
