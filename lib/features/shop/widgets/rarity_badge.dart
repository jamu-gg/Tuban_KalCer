import 'package:flutter/material.dart'; // widget dasar Flutter

import '../models/shop_item.dart'; // enum Rarity dan warnanya

/// Lencana kecil kelangkaan item (UMUM, LANGKA, EPIK, LEGENDARIS).
class RarityBadge extends StatelessWidget {
  final Rarity rarity; // tingkat kelangkaan yang ditampilkan
  const RarityBadge({super.key, required this.rarity}); // konstruktor

  @override
  Widget build(BuildContext context) { // membangun lencana
    return Container( // kotak lencana
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3), // jarak dalam
      decoration: BoxDecoration( // hiasan lencana
        color: Colors.black.withAlpha(150), // latar gelap transparan agar terbaca di atas gambar
        borderRadius: BorderRadius.circular(8), // sudut membulat
        border: Border.all(color: rarity.color, width: 1.2), // garis tepi sesuai warna kelangkaan
      ),
      child: Row( // ikon dan teks sejajar
        mainAxisSize: MainAxisSize.min, // lebar mengikuti isi
        children: [
          Icon(Icons.diamond, size: 11, color: rarity.color), // ikon permata kecil
          const SizedBox(width: 3), // jarak ikon dan teks
          Text(rarity.label, style: TextStyle(color: rarity.color, fontSize: 9.5, fontWeight: FontWeight.w800, letterSpacing: 0.6)), // teks kelangkaan
        ],
      ),
    );
  }
}
