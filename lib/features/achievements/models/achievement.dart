import 'package:flutter/material.dart'; // IconData dan Color

/// Kelompok lencana pencapaian.
enum AchievementGroup { jelajah, game, kamus } // jelajah peta, game, kamus istilah

/// Satu lencana pencapaian yang bisa dibuka pemain.
class Achievement {
  final String id; // kode unik lencana
  final String title; // nama lencana
  final String desc; // syarat membuka (ditampilkan ke pemain)
  final IconData icon; // ikon lencana
  final Color color; // warna lencana
  final AchievementGroup group; // kelompok
  final List<String> poiIds; // lokasi yang semuanya harus selesai dibaca (khusus jelajah)
  final int minPois; // jumlah minimal lokasi selesai (khusus jelajah)

  const Achievement({ // konstruktor konstan
    required this.id, // id wajib
    required this.title, // nama wajib
    required this.desc, // syarat wajib
    required this.icon, // ikon wajib
    required this.color, // warna wajib
    required this.group, // kelompok wajib
    this.poiIds = const [], // bawaan: tanpa syarat lokasi tertentu
    this.minPois = 0, // bawaan: tanpa syarat jumlah
  });
}

/// Daftar seluruh lencana di aplikasi.
const List<Achievement> achievementList = [
  Achievement(id: 'first_step', title: 'Langkah Pertama', desc: 'Selesaikan Story Card di satu lokasi.', icon: Icons.directions_walk, color: Color(0xFF66BB6A), group: AchievementGroup.jelajah, minPois: 1), // lencana pemula
  Achievement(id: 'pesisir', title: 'Penjaga Pesisir', desc: 'Selesaikan Pantai Boom dan Klenteng Kwan Sing Bio.', icon: Icons.sailing, color: Color(0xFF29B6F6), group: AchievementGroup.jelajah, poiIds: ['pantai_boom', 'klenteng_kwan_sing_bio']), // lencana pesisir
  Achievement(id: 'bumi_wali', title: 'Peziarah Bumi Wali', desc: 'Selesaikan Makam Sunan Bonang.', icon: Icons.mosque, color: Color(0xFF26A69A), group: AchievementGroup.jelajah, poiIds: ['makam_sunan_bonang']), // lencana wali
  Achievement(id: 'juru_gua', title: 'Juru Gua Akbar', desc: 'Selesaikan Gua Akbar.', icon: Icons.landscape, color: Color(0xFFAB47BC), group: AchievementGroup.jelajah, poiIds: ['gua_akbar']), // lencana gua
  Achievement(id: 'sahabat_gedog', title: 'Sahabat Gedog', desc: 'Selesaikan Tenun Gedog Kerek.', icon: Icons.checkroom, color: Color(0xFF5C6BC0), group: AchievementGroup.jelajah, poiIds: ['tenun_gedog_kerek']), // lencana tenun
  Achievement(id: 'jelajah_tuntas', title: 'Jelajah Tuntas', desc: 'Selesaikan seluruh lokasi di peta.', icon: Icons.emoji_events, color: Color(0xFFFFC107), group: AchievementGroup.jelajah, minPois: 5), // lencana puncak
  Achievement(id: 'jawara_siwalan', title: 'Jawara Siwalan', desc: 'Raih 60 poin atau lebih di game Siwalan.', icon: Icons.spa, color: Color(0xFF8D6E63), group: AchievementGroup.game), // lencana game siwalan
  Achievement(id: 'kuis_sempurna', title: 'Kuis Sempurna', desc: 'Jawab semua soal kuis dengan benar.', icon: Icons.school, color: Color(0xFFEF5350), group: AchievementGroup.game), // lencana kuis
  Achievement(id: 'combo_api', title: 'Combo Api', desc: 'Capai combo x4 di kuis.', icon: Icons.local_fire_department, color: Color(0xFFFF7043), group: AchievementGroup.game), // lencana combo
  Achievement(id: 'kolektor_kata', title: 'Kolektor Kata', desc: 'Baca 10 istilah di Kamus Tuban.', icon: Icons.menu_book, color: Color(0xFFEDAA3A), group: AchievementGroup.kamus), // lencana kamus
];

/// Mencari lencana berdasarkan id.
Achievement? findAchievement(String id) { // fungsi pencarian
  for (final a in achievementList) { // telusuri daftar
    if (a.id == id) return a; // kembalikan bila cocok
  }
  return null; // tidak ditemukan
}
