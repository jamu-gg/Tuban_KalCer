import 'dart:math' as math; // fungsi matematika (pi) untuk memutar bentuk
import 'package:flutter/material.dart'; // widget dasar Flutter

/// Pelukis motif kawung sederhana: elips-elips yang berputar membentuk bunga, diulang rapi.
class BatikKawungPainter extends CustomPainter {
  final Color color; // warna garis motif (biasanya putih transparan)
  final double cell; // ukuran satu sel motif dalam piksel
  const BatikKawungPainter({required this.color, this.cell = 34}); // konstruktor

  @override
  void paint(Canvas canvas, Size size) { // dipanggil Flutter untuk menggambar
    final paint = Paint() // kuas gambar
      ..color = color // warna garis
      ..style = PaintingStyle.stroke // hanya garis tepi, tanpa isi
      ..strokeWidth = 1.2; // ketebalan garis
    int row = 0; // nomor baris, dipakai untuk menggeser baris ganjil
    for (double y = 0; y < size.height + cell; y += cell / 2) { // telusuri baris dari atas ke bawah
      final shift = (row % 2 == 0) ? 0.0 : cell / 2; // baris ganjil digeser setengah sel agar motif berselang-seling
      for (double x = -cell; x < size.width + cell; x += cell) { // telusuri kolom dari kiri ke kanan
        canvas.save(); // simpan keadaan kanvas
        canvas.translate(x + shift, y); // pindahkan titik gambar ke pusat sel
        for (int k = 0; k < 4; k++) { // empat elips membentuk satu bunga kawung
          canvas.save(); // simpan keadaan sebelum memutar
          canvas.rotate(k * math.pi / 4); // putar 45 derajat tiap elips
          canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: cell * 0.26, height: cell * 0.76), paint); // gambar elips
          canvas.restore(); // kembalikan putaran
        }
        canvas.restore(); // kembalikan posisi kanvas
      }
      row++; // lanjut ke baris berikutnya
    }
  }

  @override
  bool shouldRepaint(BatikKawungPainter old) => old.color != color || old.cell != cell; // gambar ulang hanya bila warna atau ukuran berubah
}

/// Widget pembungkus: menampilkan motif kawung transparan memenuhi area induknya.
class BatikOverlay extends StatelessWidget {
  final Color color; // warna motif
  final double cell; // ukuran sel
  const BatikOverlay({super.key, this.color = const Color(0x33FFFFFF), this.cell = 34}); // bawaan: putih transparan 20%

  @override
  Widget build(BuildContext context) { // membangun widget
    return IgnorePointer( // motif tidak boleh menangkap ketukan
      child: CustomPaint( // area gambar kustom
        painter: BatikKawungPainter(color: color, cell: cell), // pelukis motif
        size: Size.infinite, // penuhi area yang tersedia
      ),
    );
  }
}
