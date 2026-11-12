import 'package:flutter/material.dart'; // widget dasar Flutter
import 'package:provider/provider.dart'; // membaca state

import '../../../core/database/database_helper.dart'; // hitung lokasi selesai
import '../../../core/theme/app_theme.dart'; // warna aplikasi
import '../../../core/widgets/batik_pattern.dart'; // aksen batik
import '../../achievements/models/achievement.dart'; // jumlah total lencana
import '../../achievements/providers/achievement_provider.dart'; // lencana terbuka
import '../../coin/providers/coin_provider.dart'; // saldo koin
import '../../glossary/screens/glossary_screen.dart'; // layar kamus
import '../../profile/providers/profile_provider.dart'; // nama pengguna
import '../widgets/fun_fact_card.dart'; // kartu fakta
import '../widgets/hero_card.dart'; // kartu hero

/// Tab beranda: kepala bermotif batik, Hero Card, statistik, jalan pintas, dan Fun Fact.
class DashboardTab extends StatelessWidget {
  final void Function(int) onGoTo; // fungsi pindah tab
  const DashboardTab({super.key, required this.onGoTo}); // konstruktor

  /// Menghitung jumlah lokasi peta yang sudah selesai dibaca.
  Future<int> _visited() async { // hitung lokasi
    final m = await DatabaseHelper.instance.getGameStatesByPrefix('story_'); // semua kunci story_
    return m.length; // jumlahnya
  }

  @override
  Widget build(BuildContext context) { // membangun beranda
    final name = context.watch<ProfileProvider>().profile.name; // nama pengguna
    final coins = context.watch<CoinProvider>().coins; // saldo koin
    final badges = context.watch<AchievementProvider>().count; // lencana terbuka
    return ListView(
      padding: EdgeInsets.zero, // kepala menempel ke atas
      children: [
        Container( // kepala hijau bermotif batik
          decoration: const BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.green, AppColors.greenDark]), // gradasi hijau
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)), // sudut bawah membulat
          ),
          clipBehavior: Clip.antiAlias, // potong motif di sudut
          child: Stack(children: [
            const Positioned.fill(child: BatikOverlay(color: Color(0x1FFFFFFF), cell: 46)), // motif kawung transparan
            SafeArea(bottom: false, child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 22), // jarak dalam
              child: Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Sugeng rawuh,', style: TextStyle(color: Colors.white70)), // sapaan
                  Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white)), // nama
                ])),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7), // jarak dalam
                  decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(20)), // lencana emas
                  child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.monetization_on, size: 18, color: AppColors.indigo), const SizedBox(width: 4), Text('$coins', style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.indigo))]), // koin
                ),
              ]),
            )),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.all(16), // jarak isi
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            HeroCard(onExplore: () => onGoTo(1)), // carousel tempat ikonik
            const SizedBox(height: 14), // jarak
            FutureBuilder<int>(future: _visited(), builder: (_, snap) => Row(children: [ // tiga statistik
              _Stat(icon: Icons.place, label: 'Lokasi', value: '${snap.data ?? 0}/5', color: AppColors.green), // lokasi
              const SizedBox(width: 10), // jarak
              _Stat(icon: Icons.emoji_events, label: 'Lencana', value: '$badges/${achievementList.length}', color: AppColors.gold), // lencana
              const SizedBox(width: 10), // jarak
              _Stat(icon: Icons.monetization_on, label: 'Koin', value: '$coins', color: AppColors.red), // koin
            ])),
            const SizedBox(height: 14), // jarak
            const FunFactCard(), // fakta dinamis
            const SizedBox(height: 14), // jarak
            GridView.count( // jalan pintas dua kolom
              crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 1.55, // pengaturan kisi
              children: [
                _Shortcut(icon: Icons.map, title: 'Jelajah Peta', desc: 'Baca Story Card', color: AppColors.green, onTap: () => onGoTo(1)), // peta
                _Shortcut(icon: Icons.sports_esports, title: 'Mini Games', desc: 'Kuis dan Siwalan', color: AppColors.red, onTap: () => onGoTo(2)), // game
                _Shortcut(icon: Icons.storefront, title: 'Toko', desc: 'Bingkai dan banner', color: AppColors.indigo, onTap: () => onGoTo(3)), // toko
                _Shortcut(icon: Icons.menu_book, title: 'Kamus Tuban', desc: 'Istilah budaya', color: const Color(0xFFB07A1F), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GlossaryScreen()))), // kamus
              ],
            ),
          ]),
        ),
      ],
    );
  }
}

/// Kotak statistik kecil.
class _Stat extends StatelessWidget {
  final IconData icon; final String label; final String value; final Color color; // data kotak
  const _Stat({required this.icon, required this.label, required this.value, required this.color}); // konstruktor
  @override
  Widget build(BuildContext context) { // membangun kotak
    return Expanded(child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10), // jarak tegak
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withAlpha(60))), // kotak putih bertepi
      child: Column(children: [Icon(icon, color: color), const SizedBox(height: 2), Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: AppColors.greenDark)), Text(label, style: const TextStyle(fontSize: 11, color: Colors.black54))]), // ikon, angka, label
    ));
  }
}

/// Kartu jalan pintas berwarna.
class _Shortcut extends StatelessWidget {
  final IconData icon; final String title; final String desc; final Color color; final VoidCallback onTap; // data kartu
  const _Shortcut({required this.icon, required this.title, required this.desc, required this.color, required this.onTap}); // konstruktor
  @override
  Widget build(BuildContext context) { // membangun kartu
    return Material(
      color: color, borderRadius: BorderRadius.circular(18), clipBehavior: Clip.antiAlias, // permukaan berwarna
      child: InkWell(onTap: onTap, child: Stack(children: [
        const Positioned.fill(child: BatikOverlay(color: Color(0x18FFFFFF), cell: 30)), // aksen batik
        Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Icon(icon, color: Colors.white, size: 28), // ikon
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)), Text(desc, style: const TextStyle(color: Colors.white70, fontSize: 11.5))]), // judul dan keterangan
        ])),
      ])),
    );
  }
}
