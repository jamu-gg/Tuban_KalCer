import 'dart:math' as math; // sin, cos, pi
import 'package:flutter/material.dart'; // widget dasar Flutter

import '../data/poi_data.dart'; // posisi lokasi untuk jalan

/// Latar peta Tuban berupa ilustrasi vektor: laut bergelombang, garis pantai, sawah, hutan, sungai, jalan, dan pohon siwalan.
class MapCanvas extends StatelessWidget {
  final Animation<double> anim; // animasi 0..1 berulang (ombak dan kapal)
  const MapCanvas({super.key, required this.anim}); // konstruktor

  @override
  Widget build(BuildContext context) { // membangun latar
    return RepaintBoundary(child: CustomPaint(painter: _MapPainter(anim), size: Size.infinite)); // area gambar
  }
}

class _MapPainter extends CustomPainter {
  final Animation<double> anim; // animasi
  _MapPainter(this.anim) : super(repaint: anim); // gambar ulang tiap detak

  double _coastY(double x, double w, double h) => h * 0.17 + h * 0.025 * math.sin(x / w * math.pi * 3 + 1); // tinggi garis pantai di posisi x

  @override
  void paint(Canvas canvas, Size size) { // menggambar peta
    final w = size.width, h = size.height; // singkatan ukuran
    final t = anim.value; // nilai animasi
    final rect = Offset.zero & size; // seluruh area
    canvas.drawRect(rect, Paint()..shader = const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFE3EFC4), Color(0xFFC9DFA0)]).createShader(rect)); // daratan hijau muda
    _fields(canvas, w, h); // sawah
    _forest(canvas, w, h); // hutan
    _river(canvas, w, h); // sungai
    _roads(canvas, w, h); // jalan antar lokasi
    _palms(canvas, w, h); // pohon siwalan
    final sea = Path()..moveTo(0, 0)..lineTo(w, 0); // jalur laut
    for (double x = w; x >= 0; x -= 8) { sea.lineTo(x, _coastY(x, w, h)); } // ikuti garis pantai dari kanan ke kiri
    sea.close(); // tutup jalur
    canvas.drawPath(sea, Paint()..shader = const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF2D8FC7), Color(0xFF7CC8EC)]).createShader(Rect.fromLTWH(0, 0, w, h * 0.22))); // isi laut
    final wave = Paint()..color = Colors.white.withAlpha(110)..style = PaintingStyle.stroke..strokeWidth = 1.5; // kuas ombak
    for (int r = 0; r < 3; r++) { // tiga baris ombak
      final p = Path(); // jalur ombak
      final y0 = h * (0.05 + r * 0.04); // tinggi baris
      p.moveTo(0, y0); // mulai di kiri
      for (double x = 0; x <= w; x += 6) { p.lineTo(x, y0 + math.sin(x / w * math.pi * 8 + t * 2 * math.pi + r * 1.3) * 2.5); } // gelombang bergerak
      canvas.drawPath(p, wave); // gambar baris
    }
    final shore = Path(); // garis pantai untuk buih dan pasir
    shore.moveTo(0, _coastY(0, w, h)); // mulai di kiri
    for (double x = 0; x <= w; x += 8) { shore.lineTo(x, _coastY(x, w, h)); } // telusuri pantai
    canvas.drawPath(shore, Paint()..color = const Color(0xFFF1D9A5)..style = PaintingStyle.stroke..strokeWidth = 8); // pasir
    canvas.drawPath(shore, Paint()..color = Colors.white.withAlpha((160 + 90 * math.sin(t * 2 * math.pi)).round().clamp(0, 255))..style = PaintingStyle.stroke..strokeWidth = 2.2); // buih berdenyut
    final sx = w * (0.12 + 0.6 * t); // posisi kapal bergerak
    final sy = h * 0.10; // tinggi kapal
    canvas.drawPath(Path()..moveTo(sx - 16, sy)..lineTo(sx + 16, sy)..lineTo(sx + 10, sy + 8)..lineTo(sx - 10, sy + 8)..close(), Paint()..color = const Color(0xFF5D4037)); // lambung
    canvas.drawPath(Path()..moveTo(sx, sy - 22)..lineTo(sx + 13, sy - 3)..lineTo(sx, sy - 3)..close(), Paint()..color = Colors.white); // layar
    _text(canvas, 'Laut Jawa', Offset(w * 0.04, h * 0.015), const Color(0xFF0D3B66)); // label laut
    _compass(canvas, Offset(w - 38, h - 44)); // kompas
  }

  void _fields(Canvas c, double w, double h) { // petak sawah
    final shades = [const Color(0xFFB9D67A), const Color(0xFFA7C968), const Color(0xFFCADF8E)]; // tiga warna sawah
    for (int i = 0; i < 14; i++) { // 14 petak
      final x = w * (0.02 + (i % 5) * 0.075), y = h * (0.58 + (i ~/ 5) * 0.08); // posisi grid kiri bawah
      c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x, y, w * 0.065, h * 0.065), const Radius.circular(4)), Paint()..color = shades[i % 3]); // satu petak
    }
  }

  void _forest(Canvas c, double w, double h) { // hutan jati di kanan bawah
    final p = Paint()..color = const Color(0xFF6E9F4A); // warna hutan
    for (int i = 0; i < 22; i++) { // 22 tajuk
      final x = w * (0.66 + ((i * 37) % 30) / 100), y = h * (0.66 + ((i * 53) % 28) / 100); // sebaran tetap
      c.drawCircle(Offset(x, y), w * (0.022 + ((i * 7) % 4) * 0.005), p); // satu tajuk
    }
  }

  void _river(Canvas c, double w, double h) { // sungai bermuara ke laut
    final p = Path()..moveTo(w * 0.86, _coastY(w * 0.86, w, h))..cubicTo(w * 0.80, h * 0.30, w * 0.93, h * 0.45, w * 0.84, h * 0.62)..cubicTo(w * 0.78, h * 0.72, w * 0.90, h * 0.85, w * 0.82, h); // aliran sungai
    c.drawPath(p, Paint()..color = const Color(0xFF7CC8EC)..style = PaintingStyle.stroke..strokeWidth = 7..strokeCap = StrokeCap.round); // sungai
  }

  void _roads(Canvas c, double w, double h) { // jalan menghubungkan lokasi
    final pts = poiList.map((p) => Offset(p.x * w, p.y * h)).toList(); // posisi tiap lokasi
    final road = Path()..moveTo(pts[0].dx, pts[0].dy); // mulai dari lokasi pertama
    for (int i = 1; i < pts.length; i++) { // sambungkan lokasi berikutnya dengan lengkung
      final a = pts[i - 1], b = pts[i]; // dua titik berurutan
      road.quadraticBezierTo((a.dx + b.dx) / 2 + (i.isEven ? 30 : -30), (a.dy + b.dy) / 2, b.dx, b.dy); // lengkung halus
    }
    c.drawPath(road, Paint()..color = const Color(0xFFF3E5C0)..style = PaintingStyle.stroke..strokeWidth = 9..strokeCap = StrokeCap.round); // badan jalan
    c.drawPath(road, Paint()..color = const Color(0xFFB59A62)..style = PaintingStyle.stroke..strokeWidth = 1.4); // garis tengah
  }

  void _palms(Canvas c, double w, double h) { // pohon siwalan kecil sebagai hiasan
    const spots = [Offset(0.10, 0.30), Offset(0.18, 0.40), Offset(0.52, 0.48), Offset(0.84, 0.28), Offset(0.12, 0.88), Offset(0.58, 0.90), Offset(0.92, 0.55), Offset(0.50, 0.66)]; // titik pohon
    final trunk = Paint()..color = const Color(0xFF6D4C41)..strokeWidth = 2.4..strokeCap = StrokeCap.round; // kuas batang
    final leaf = Paint()..color = const Color(0xFF2E7D32)..style = PaintingStyle.stroke..strokeWidth = 2.2..strokeCap = StrokeCap.round; // kuas daun
    for (final s in spots) { // tiap pohon
      final base = Offset(s.dx * w, s.dy * h); // pangkal
      final top = base + const Offset(2, -22); // pucuk
      c.drawLine(base, top, trunk); // batang
      for (final a in const [-170, -130, -90, -50, -10]) { // lima pelepah
        final r = a * math.pi / 180; // radian
        c.drawLine(top, top + Offset(math.cos(r) * 12, math.sin(r) * 8 + 3), leaf); // satu pelepah
      }
    }
  }

  void _compass(Canvas c, Offset at) { // kompas kecil
    c.drawCircle(at, 20, Paint()..color = Colors.white.withAlpha(200)); // dasar
    c.drawCircle(at, 20, Paint()..color = const Color(0xFF26376B)..style = PaintingStyle.stroke..strokeWidth = 1.4); // tepi
    c.drawPath(Path()..moveTo(at.dx, at.dy - 16)..lineTo(at.dx + 5, at.dy)..lineTo(at.dx - 5, at.dy)..close(), Paint()..color = const Color(0xFFB8402F)); // panah utara merah
    c.drawPath(Path()..moveTo(at.dx, at.dy + 16)..lineTo(at.dx + 5, at.dy)..lineTo(at.dx - 5, at.dy)..close(), Paint()..color = const Color(0xFF26376B)); // panah selatan
    _textImpl(c, 'U', at + const Offset(-4, -34), const Color(0xFF26376B), 11, true); // huruf U
  }

  void _text(Canvas canvas, String s, Offset at, Color color) => _textImpl(canvas, s, at, color, 13, false); // teks miring biasa
  void _textImpl(Canvas canvas, String s, Offset at, Color color, double size, bool bold) { // pelukis teks
    final tp = TextPainter(text: TextSpan(text: s, style: TextStyle(color: color, fontSize: size, fontStyle: bold ? FontStyle.normal : FontStyle.italic, fontWeight: bold ? FontWeight.w900 : FontWeight.w500)), textDirection: TextDirection.ltr)..layout(); // ukur teks
    tp.paint(canvas, at); // gambar teks
  }

  @override
  bool shouldRepaint(_MapPainter old) => false; // gerak ditangani animasi
}
