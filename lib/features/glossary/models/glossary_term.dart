import 'package:flutter/material.dart'; // IconData dan Color

/// Kelompok istilah di Kamus Tuban.
enum GlossCategory { kuliner, tenun, tempat, sejarah, sapaan } // lima kelompok

/// Tambahan sifat untuk kelompok: nama, ikon, warna.
extension GlossCategoryInfo on GlossCategory {
  String get label { // nama kelompok
    switch (this) {
      case GlossCategory.kuliner: return 'Kuliner'; // makanan dan minuman
      case GlossCategory.tenun: return 'Tenun & Batik'; // kain
      case GlossCategory.tempat: return 'Tempat'; // lokasi
      case GlossCategory.sejarah: return 'Sejarah'; // tokoh dan peristiwa
      case GlossCategory.sapaan: return 'Sapaan'; // bahasa sehari-hari
    }
  }

  IconData get icon { // ikon kelompok
    switch (this) {
      case GlossCategory.kuliner: return Icons.local_drink; // gelas
      case GlossCategory.tenun: return Icons.checkroom; // pakaian
      case GlossCategory.tempat: return Icons.place; // penanda tempat
      case GlossCategory.sejarah: return Icons.account_balance; // bangunan bersejarah
      case GlossCategory.sapaan: return Icons.waving_hand; // tangan menyapa
    }
  }

  Color get color { // warna kelompok
    switch (this) {
      case GlossCategory.kuliner: return const Color(0xFFB07A1F); // cokelat emas
      case GlossCategory.tenun: return const Color(0xFF26376B); // indigo
      case GlossCategory.tempat: return const Color(0xFF1F7A4F); // hijau
      case GlossCategory.sejarah: return const Color(0xFFB8402F); // merah bata
      case GlossCategory.sapaan: return const Color(0xFF0277BD); // biru
    }
  }
}

/// Satu istilah beserta arti, penjelasan, dan contoh penggunaan.
class GlossaryTerm {
  final String id; // kode unik
  final String term; // istilah
  final GlossCategory category; // kelompok
  final String meaning; // arti singkat
  final String detail; // penjelasan lebih panjang
  final String? example; // contoh kalimat (opsional)
  const GlossaryTerm({required this.id, required this.term, required this.category, required this.meaning, required this.detail, this.example}); // konstruktor
}
