import 'package:flutter/material.dart'; // impor widget dasar Flutter (Color, IconData)

/// Kategori item yang dijual di toko kustomisasi.
enum ItemCategory { frame, banner, theme, title, badge } // lima jenis item gaya Discord

/// Tingkat kelangkaan item (seperti rarity pada Discord Shop).
enum Rarity { umum, langka, epik, legendaris } // dari paling biasa sampai paling istimewa

/// Tambahan sifat untuk Rarity: label teks dan warna lencana.
extension RarityInfo on Rarity {
  String get label { // teks yang tampil di lencana
    switch (this) { // pilih berdasarkan tingkat
      case Rarity.umum: return 'UMUM'; // tingkat 1
      case Rarity.langka: return 'LANGKA'; // tingkat 2
      case Rarity.epik: return 'EPIK'; // tingkat 3
      case Rarity.legendaris: return 'LEGENDARIS'; // tingkat 4
    }
  }

  Color get color { // warna lencana
    switch (this) { // pilih berdasarkan tingkat
      case Rarity.umum: return const Color(0xFF90A4AE); // abu kebiruan
      case Rarity.langka: return const Color(0xFF42A5F5); // biru
      case Rarity.epik: return const Color(0xFFAB47BC); // ungu
      case Rarity.legendaris: return const Color(0xFFFFC107); // emas
    }
  }
}

/// Model data satu item toko (bingkai, banner, tema, gelar, atau pin).
class ShopItem {
  final String id; // kode unik item, contoh: "frame_neon_batik"
  final String name; // nama item yang tampil di toko
  final ItemCategory category; // jenis item
  final int price; // harga dalam KalCer Coins
  final Color primary; // warna utama untuk visualisasi item
  final Color secondary; // warna kedua untuk gradasi
  final IconData? icon; // ikon (dipakai oleh badge)
  final String? text; // teks (dipakai oleh gelar/title)
  final Rarity rarity; // tingkat kelangkaan
  final String description; // keterangan singkat bernuansa budaya Tuban

  const ShopItem({ // konstruktor konstan
    required this.id, // id wajib diisi
    required this.name, // nama wajib diisi
    required this.category, // kategori wajib diisi
    required this.price, // harga wajib diisi
    required this.primary, // warna utama wajib diisi
    this.secondary = Colors.black, // warna kedua, default hitam
    this.icon, // ikon opsional
    this.text, // teks opsional
    this.rarity = Rarity.umum, // kelangkaan bawaan: umum
    this.description = '', // keterangan bawaan kosong
  });
}

/// Katalog item yang tersedia di toko (disimpan di kode, bukan di database).
const List<ShopItem> shopCatalog = [ // daftar seluruh item toko
  // ---------- Bingkai Avatar ----------
  ShopItem(id: 'frame_ombak_boom', name: 'Ombak Pantai Boom', category: ItemCategory.frame, price: 90, primary: Color(0xFF4FC3F7), rarity: Rarity.umum, description: 'Bingkai biru laut yang berdenyut pelan seperti ombak di Pantai Boom.'), // bingkai laut
  ShopItem(id: 'frame_neon_batik', name: 'Bingkai Neon Batik Gedog', category: ItemCategory.frame, price: 120, primary: Color(0xFF00E5FF), rarity: Rarity.langka, description: 'Cahaya neon yang terinspirasi garis-garis tenun Batik Gedog.'), // bingkai neon biru
  ShopItem(id: 'frame_gua_akbar', name: 'Gua Akbar Glow', category: ItemCategory.frame, price: 150, primary: Color(0xFFB388FF), rarity: Rarity.langka, description: 'Pendar ungu seperti cahaya yang menyentuh stalaktit di Gua Akbar.'), // bingkai ungu menyala
  ShopItem(id: 'frame_api_ksatria', name: 'Bingkai Aura Api Ksatria', category: ItemCategory.frame, price: 200, primary: Color(0xFFFF6D00), rarity: Rarity.epik, description: 'Aura api jingga untuk para ksatria penjaga cerita Tuban.'), // bingkai api oranye
  ShopItem(id: 'frame_siwalan_emas', name: 'Daun Siwalan Emas', category: ItemCategory.frame, price: 260, primary: Color(0xFFFFC107), rarity: Rarity.legendaris, description: 'Bingkai emas langka berbentuk kipas daun siwalan, lambang Tuban.'), // bingkai emas
  // ---------- Banner Profil ----------
  ShopItem(id: 'banner_pantai_boom', name: 'Pemandangan Pantai Boom', category: ItemCategory.banner, price: 100, primary: Color(0xFF29B6F6), secondary: Color(0xFFFFCC80), rarity: Rarity.umum, description: 'Langit senja bertemu laut di tepi Pantai Boom.'), // banner laut dan pasir
  ShopItem(id: 'banner_alun_malam', name: 'Vibe Malam Alun-Alun Tuban', category: ItemCategory.banner, price: 130, primary: Color(0xFF1A237E), secondary: Color(0xFFFFD54F), rarity: Rarity.langka, description: 'Suasana malam alun-alun kota dengan lampu yang hangat.'), // banner malam kota
  ShopItem(id: 'banner_gua_akbar', name: 'Lorong Gua Akbar', category: ItemCategory.banner, price: 170, primary: Color(0xFF263238), secondary: Color(0xFF7E57C2), rarity: Rarity.epik, description: 'Lorong gua yang gelap dengan kilau ungu di dindingnya.'), // banner gua
  ShopItem(id: 'banner_gedog_indigo', name: 'Tenun Gedog Indigo', category: ItemCategory.banner, price: 220, primary: Color(0xFF26376B), secondary: Color(0xFFEDAA3A), rarity: Rarity.epik, description: 'Kain gedog biru nila dengan benang emas legen.'), // banner tenun
  // ---------- Warna Tema ----------
  ShopItem(id: 'theme_siwalan_hijau', name: 'Hijau Siwalan', category: ItemCategory.theme, price: 80, primary: Color(0xFF1F7A4F), secondary: Color(0xFF0E4A31), rarity: Rarity.umum, description: 'Hijau daun siwalan yang teduh.'), // tema hijau
  ShopItem(id: 'theme_pesisir_blue', name: 'Tuban Pesisir Blue', category: ItemCategory.theme, price: 80, primary: Color(0xFF0277BD), secondary: Color(0xFF4FC3F7), rarity: Rarity.umum, description: 'Biru pesisir utara Jawa.'), // tema biru pesisir
  ShopItem(id: 'theme_klenteng_merah', name: 'Merah Klenteng', category: ItemCategory.theme, price: 140, primary: Color(0xFFB8402F), secondary: Color(0xFFEDAA3A), rarity: Rarity.langka, description: 'Merah bata dan emas ala Klenteng Kwan Sing Bio.'), // tema merah
  ShopItem(id: 'theme_ksatria_gold', name: 'Ksatria Gold', category: ItemCategory.theme, price: 160, primary: Color(0xFFFF8F00), secondary: Color(0xFFFFE082), rarity: Rarity.epik, description: 'Gradasi emas yang megah.'), // tema emas
  // ---------- Gelar ----------
  ShopItem(id: 'title_legen', name: 'Pecinta Legen', category: ItemCategory.title, price: 60, primary: Color(0xFFFFCA28), text: 'Pecinta Legen', rarity: Rarity.umum, description: 'Untuk yang selalu mencari minuman nira siwalan yang segar.'), // gelar legen
  ShopItem(id: 'title_jawara_trivia', name: 'Jawara Trivia', category: ItemCategory.title, price: 90, primary: Color(0xFFFFD54F), text: 'Jawara Trivia', rarity: Rarity.langka, description: 'Gelar bagi pemenang kuis budaya.'), // gelar kuis
  ShopItem(id: 'title_pena_sejarah', name: 'Pena Sejarah Tuban', category: ItemCategory.title, price: 110, primary: Color(0xFF80CBC4), text: 'Pena Sejarah Tuban', rarity: Rarity.langka, description: 'Gelar bagi pembaca sejarah yang tekun.'), // gelar sejarah
  ShopItem(id: 'title_penjelajah', name: 'Penjelajah Bumi Wali', category: ItemCategory.title, price: 180, primary: Color(0xFFA5D6A7), text: 'Penjelajah Bumi Wali', rarity: Rarity.epik, description: 'Gelar bagi penjelajah yang menyusuri banyak lokasi.'), // gelar penjelajah
  // ---------- Pin / Badge ----------
  ShopItem(id: 'badge_siwalan', name: 'Pin Siwalan', category: ItemCategory.badge, price: 50, primary: Color(0xFF8D6E63), icon: Icons.spa, rarity: Rarity.umum, description: 'Pin buah dan daun siwalan.'), // pin siwalan
  ShopItem(id: 'badge_keris', name: 'Pin Keris', category: ItemCategory.badge, price: 60, primary: Color(0xFFCFD8DC), icon: Icons.shield, rarity: Rarity.langka, description: 'Pin pusaka bergaya keris.'), // pin keris
  ShopItem(id: 'badge_kapal', name: 'Pin Kapal Bandar', category: ItemCategory.badge, price: 80, primary: Color(0xFF4FC3F7), icon: Icons.sailing, rarity: Rarity.langka, description: 'Mengenang Tuban sebagai kota bandar dagang.'), // pin kapal
  ShopItem(id: 'badge_kawung', name: 'Pin Kawung', category: ItemCategory.badge, price: 120, primary: Color(0xFFEDAA3A), icon: Icons.auto_awesome, rarity: Rarity.epik, description: 'Pin motif kawung berkilau.'), // pin kawung
];

/// Mencari item di katalog berdasarkan id. Mengembalikan null jika tidak ada.
ShopItem? findItem(String? id) { // fungsi pencarian item
  if (id == null) return null; // jika id kosong, tidak ada item
  for (final item in shopCatalog) { // telusuri seluruh katalog
    if (item.id == id) return item; // kembalikan item bila id cocok
  }
  return null; // tidak ditemukan
}
