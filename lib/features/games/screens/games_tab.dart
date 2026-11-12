import 'package:flutter/material.dart'; // widget dasar Flutter

import '../../../core/database/database_helper.dart'; // baca rekor
import '../../../core/theme/app_theme.dart'; // warna aplikasi
import '../../../core/widgets/tuban_scene.dart'; // ilustrasi kartu
import 'quiz_screen.dart'; // layar kuis
import 'siwalan_game_screen.dart'; // layar game siwalan

/// Tab mini games: dua permainan bergambar beserta rekor tertingginya.
class GamesTab extends StatefulWidget {
  const GamesTab({super.key}); // konstruktor
  @override
  State<GamesTab> createState() => _GamesTabState(); // buat state
}

class _GamesTabState extends State<GamesTab> {
  /// Membaca rekor dua game dari SQLite.
  Future<List<String>> _loadBest() async { // muat rekor
    final q = await DatabaseHelper.instance.getGameState('best_quiz') ?? '0'; // rekor kuis
    final s = await DatabaseHelper.instance.getGameState('best_siwalan') ?? '0'; // rekor siwalan
    return [q, s]; // kembalikan keduanya
  }

  /// Membuka layar game lalu menyegarkan rekor setelah kembali.
  Future<void> _play(Widget screen) async { // main game
    await Navigator.push(context, MaterialPageRoute(builder: (_) => screen)); // buka layar game
    if (mounted) setState(() {}); // segarkan rekor
  }

  @override
  Widget build(BuildContext context) { // membangun tab
    return SafeArea(child: FutureBuilder<List<String>>(
      future: _loadBest(), // sumber data
      builder: (context, snap) { // snap berisi hasil
        final best = snap.data ?? ['0', '0']; // rekor, 0 bila belum ada
        return ListView(padding: const EdgeInsets.all(16), children: [
          const Text('Mini Games', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.greenDark)), // judul
          const SizedBox(height: 12), // jarak
          _GameCard(kind: SceneKind.siwalan, phase: 0, title: 'Ketangkasan Siwalan', desc: 'Tangkap siwalan dengan keranjang rotan. Awas buah busuk!', record: 'Rekor: ${best[1]} poin', color: AppColors.green, onTap: () => _play(const SiwalanGameScreen())), // game siwalan
          const SizedBox(height: 14), // jarak
          _GameCard(kind: SceneKind.tenun, phase: 1, title: 'Kuis Trivia Budaya', desc: '5 soal, bonus combo, dan penjelasan di tiap jawaban.', record: 'Rekor: ${best[0]} koin', color: AppColors.red, onTap: () => _play(const QuizScreen())), // kuis
        ]);
      },
    ));
  }
}

/// Kartu game dengan ilustrasi di bagian atas.
class _GameCard extends StatelessWidget {
  final SceneKind kind; final int phase; final String title; final String desc; final String record; final Color color; final VoidCallback onTap; // data kartu
  const _GameCard({required this.kind, required this.phase, required this.title, required this.desc, required this.record, required this.color, required this.onTap}); // konstruktor
  @override
  Widget build(BuildContext context) { // membangun kartu
    return Material(
      color: Colors.white, borderRadius: BorderRadius.circular(22), clipBehavior: Clip.antiAlias, elevation: 2, // permukaan putih
      child: InkWell(onTap: onTap, child: Column(children: [
        SizedBox(height: 130, width: double.infinity, child: TubanScene(kind: kind, phase: phase)), // ilustrasi
        Padding(padding: const EdgeInsets.all(14), child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: color)), // judul
            const SizedBox(height: 3), // jarak
            Text(desc, style: const TextStyle(fontSize: 12.5, color: Colors.black54)), // keterangan
            const SizedBox(height: 6), // jarak
            Row(children: [const Icon(Icons.emoji_events, size: 15, color: AppColors.gold), const SizedBox(width: 4), Text(record, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700))]), // rekor
          ])),
          FilledButton(onPressed: onTap, style: FilledButton.styleFrom(backgroundColor: color), child: const Text('Main')), // tombol main
        ])),
      ])),
    );
  }
}
