import 'package:flutter/material.dart'; // widget dasar Flutter

import '../../../core/theme/app_theme.dart'; // warna aplikasi

/// Menampilkan pop-up hadiah koin setelah materi dibaca atau game selesai.
Future<void> showRewardDialog(
  BuildContext context, { // konteks tempat dialog ditampilkan
  required int coins, // jumlah koin yang didapat
  required String message, // keterangan hadiah
}) {
  return showDialog<void>( // tampilkan dialog
    context: context, // konteks layar
    builder: (ctx) => AlertDialog( // isi dialog
      backgroundColor: AppColors.cream, // latar krem
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)), // sudut membulat
      content: Column( // susun isi secara vertikal
        mainAxisSize: MainAxisSize.min, // tinggi mengikuti isi
        children: [
          const CircleAvatar( // lingkaran emas sebagai koin
            radius: 34, // ukuran koin
            backgroundColor: AppColors.gold, // warna emas
            child: Text('K', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: AppColors.indigo)), // huruf K
          ),
          const SizedBox(height: 14), // jarak
          Text('+$coins KalCer Coins', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.greenDark)), // jumlah koin
          const SizedBox(height: 6), // jarak
          Text(message, textAlign: TextAlign.center), // keterangan
        ],
      ),
      actions: [
        FilledButton(onPressed: () => Navigator.pop(ctx), child: const Text('Lanjut')), // tombol menutup dialog
      ],
      actionsAlignment: MainAxisAlignment.center, // tombol di tengah
    ),
  );
}
