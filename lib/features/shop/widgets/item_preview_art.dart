import 'package:flutter/material.dart'; // widget dasar Flutter

import '../../../core/widgets/batik_pattern.dart'; // motif batik transparan
import '../models/shop_item.dart'; // model item

/// Panel gelap berisi gambar pratinjau item, sesuai kategorinya (gaya etalase Discord Shop).
class ItemPreviewArt extends StatelessWidget {
  final ShopItem item; // item yang digambar
  const ItemPreviewArt({super.key, required this.item}); // konstruktor

  /// Gambar inti item menurut kategori.
  Widget _art() { // pilih gambar
    switch (item.category) { // berdasarkan kategori
      case ItemCategory.frame: // bingkai: avatar bulat dengan cincin berpendar
        return Container( // cincin bingkai
          width: 78, height: 78, // ukuran cincin
          padding: const EdgeInsets.all(4), // ketebalan cincin
          decoration: BoxDecoration( // hiasan cincin
            shape: BoxShape.circle, // bulat
            color: item.primary, // warna cincin
            boxShadow: [BoxShadow(color: item.primary.withAlpha(200), blurRadius: 16, spreadRadius: 2)], // efek pendar
          ),
          child: const CircleAvatar(backgroundColor: Color(0xFF3B3D44), child: Icon(Icons.person, size: 34, color: Colors.white70)), // avatar contoh
        );
      case ItemCategory.banner: // banner: gradasi dengan motif batik
        return ClipRRect( // potong sudut
          borderRadius: BorderRadius.circular(10), // sudut membulat
          child: SizedBox(
            width: 124, height: 66, // ukuran banner contoh
            child: Stack(children: [
              Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [item.primary, item.secondary]))), // gradasi banner
              const Positioned.fill(child: BatikOverlay(color: Color(0x40FFFFFF), cell: 26)), // motif batik halus di atas gradasi
            ]),
          ),
        );
      case ItemCategory.theme: // tema: kartu mini bergradasi
        return Container( // kartu mini
          width: 112, height: 72, // ukuran kartu
          padding: const EdgeInsets.all(8), // jarak dalam
          decoration: BoxDecoration( // hiasan kartu
            borderRadius: BorderRadius.circular(10), // sudut membulat
            gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [item.primary, item.secondary]), // gradasi tema
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const CircleAvatar(radius: 9, backgroundColor: Colors.white38), // avatar mini
            const SizedBox(height: 6), // jarak
            Container(height: 5, width: 60, decoration: BoxDecoration(color: Colors.white54, borderRadius: BorderRadius.circular(3))), // garis nama mini
            const SizedBox(height: 4), // jarak
            Container(height: 5, width: 40, decoration: BoxDecoration(color: Colors.white30, borderRadius: BorderRadius.circular(3))), // garis kedua mini
          ]),
        );
      case ItemCategory.title: // gelar: label pil
        return Container( // label gelar
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), // jarak dalam
          decoration: BoxDecoration( // hiasan label
            color: Colors.black.withAlpha(90), // latar gelap transparan
            borderRadius: BorderRadius.circular(20), // bentuk pil
            border: Border.all(color: item.primary), // garis tepi warna gelar
          ),
          child: Text(item.text ?? item.name, textAlign: TextAlign.center, style: TextStyle(color: item.primary, fontWeight: FontWeight.w700, fontSize: 12)), // teks gelar
        );
      case ItemCategory.badge: // pin: ikon dalam lingkaran
        return Container( // lingkaran pin
          width: 66, height: 66, // ukuran lingkaran
          decoration: BoxDecoration( // hiasan lingkaran
            shape: BoxShape.circle, // bulat
            color: item.primary.withAlpha(45), // latar warna pin transparan
            border: Border.all(color: item.primary, width: 2), // garis tepi pin
          ),
          child: Icon(item.icon, size: 32, color: item.primary), // ikon pin
        );
    }
  }

  @override
  Widget build(BuildContext context) { // membangun panel
    return Container( // panel gelap
      decoration: BoxDecoration( // hiasan panel
        gradient: LinearGradient( // gradasi gelap bernuansa warna kelangkaan
          begin: Alignment.topLeft, // mulai kiri atas
          end: Alignment.bottomRight, // berakhir kanan bawah
          colors: [const Color(0xFF2B2D31), Color.lerp(const Color(0xFF1E1F22), item.rarity.color, 0.25)!], // abu gelap ke gelap berwarna
        ),
      ),
      child: Stack(children: [
        const Positioned.fill(child: BatikOverlay(color: Color(0x12FFFFFF), cell: 40)), // motif batik sangat tipis sebagai latar
        Center(child: _art()), // gambar item di tengah
      ]),
    );
  }
}
