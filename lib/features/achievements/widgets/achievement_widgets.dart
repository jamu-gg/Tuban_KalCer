import 'package:flutter/material.dart'; // widget dasar Flutter
import 'package:provider/provider.dart'; // membaca state

import '../../../core/theme/app_theme.dart'; // warna aplikasi
import '../models/achievement.dart'; // model lencana
import '../providers/achievement_provider.dart'; // state lencana

/// Menampilkan notifikasi emas "Lencana baru!" di bagian bawah layar.
void showAchievementToast(BuildContext context, Achievement a) { // tampilkan toast
  ScaffoldMessenger.of(context).showSnackBar( // pakai SnackBar bawaan
    SnackBar(
      behavior: SnackBarBehavior.floating, // melayang di atas konten
      backgroundColor: AppColors.indigo, // latar indigo
      duration: const Duration(seconds: 3), // tampil 3 detik
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: const BorderSide(color: AppColors.gold, width: 1.5)), // tepi emas
      content: Row(children: [
        Icon(a.icon, color: a.color), // ikon lencana
        const SizedBox(width: 10), // jarak
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          const Text('Lencana baru terbuka!', style: TextStyle(color: AppColors.gold, fontSize: 11, fontWeight: FontWeight.w700)), // judul kecil
          Text(a.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)), // nama lencana
        ])),
      ]),
    ),
  );
}

/// Membuka lencana dan langsung menampilkan toast bila baru. Aman dipanggil berulang.
Future<void> unlockWithToast(BuildContext context, String id) async { // buka + toast
  final provider = context.read<AchievementProvider>(); // ambil penyedia lencana
  final got = await provider.unlock(id); // coba buka
  if (got != null && context.mounted) showAchievementToast(context, got); // tampilkan toast bila baru
}

/// Kisi lencana: yang terbuka berwarna, yang terkunci abu-abu.
class AchievementGrid extends StatelessWidget {
  final AchievementGroup? only; // filter kelompok; null = semua
  const AchievementGrid({super.key, this.only}); // konstruktor

  @override
  Widget build(BuildContext context) { // membangun kisi
    final prov = context.watch<AchievementProvider>(); // pantau perubahan lencana
    final list = achievementList.where((a) => only == null || a.group == only).toList(); // saring daftar
    return GridView.builder( // kisi yang menyesuaikan tinggi
      shrinkWrap: true, // tinggi mengikuti isi
      physics: const NeverScrollableScrollPhysics(), // gulir ditangani induk
      itemCount: list.length, // jumlah lencana
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 0.82), // tiga kolom
      itemBuilder: (_, i) { // bangun tiap sel
        final a = list[i]; // lencana
        final on = prov.isUnlocked(a.id); // terbuka?
        return GestureDetector(
          onTap: () => showDialog<void>(context: context, builder: (ctx) => AlertDialog( // dialog rincian
            title: Row(children: [Icon(a.icon, color: on ? a.color : Colors.grey), const SizedBox(width: 8), Expanded(child: Text(a.title))]), // judul dialog
            content: Text(on ? 'Terbuka. ${a.desc}' : 'Terkunci. ${a.desc}'), // syarat
            actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Tutup'))], // tombol tutup
          )),
          child: Container(
            padding: const EdgeInsets.all(8), // jarak dalam
            decoration: BoxDecoration( // kartu lencana
              color: on ? Colors.white : Colors.black.withAlpha(12), // latar sesuai status
              borderRadius: BorderRadius.circular(14), // sudut membulat
              border: Border.all(color: on ? a.color : Colors.black12, width: on ? 2 : 1), // tepi berwarna bila terbuka
            ),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              CircleAvatar(radius: 22, backgroundColor: on ? a.color.withAlpha(40) : Colors.black12, child: Icon(on ? a.icon : Icons.lock_outline, color: on ? a.color : Colors.black38)), // ikon lencana atau gembok
              const SizedBox(height: 6), // jarak
              Text(a.title, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: on ? AppColors.greenDark : Colors.black45)), // nama
            ]),
          ),
        );
      },
    );
  }
}
