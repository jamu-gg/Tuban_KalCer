import 'package:flutter/material.dart'; // widget dasar Flutter
import 'package:provider/provider.dart'; // membaca state

import '../../../core/theme/app_theme.dart'; // warna aplikasi
import '../../achievements/widgets/achievement_widgets.dart'; // kisi lencana
import '../providers/profile_provider.dart'; // state profil
import '../widgets/discord_profile_card.dart'; // kartu profil

/// Tab profil: kartu gaya Discord, tombol ganti nama, dan koleksi lencana.
class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key}); // konstruktor

  /// Dialog untuk mengganti nama pengguna.
  Future<void> _rename(BuildContext context) async { // ubah nama
    final provider = context.read<ProfileProvider>(); // penyedia profil
    final ctrl = TextEditingController(text: provider.profile.name); // isi awal nama sekarang
    final result = await showDialog<String>(
      context: context, // konteks layar
      builder: (ctx) => AlertDialog(
        title: const Text('Ganti nama'), // judul
        content: TextField(controller: ctrl, maxLength: 20, decoration: const InputDecoration(hintText: 'Nama baru')), // kolom isian
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')), // batal
          FilledButton(onPressed: () => Navigator.pop(ctx, ctrl.text), child: const Text('Simpan')), // simpan
        ],
      ),
    );
    if (result != null) await provider.updateName(result); // simpan bila tidak dibatalkan
  }

  @override
  Widget build(BuildContext context) { // membangun tab
    return SafeArea(child: ListView(children: [
      const DiscordProfileCard(), // kartu profil
      Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: OutlinedButton.icon(onPressed: () => _rename(context), icon: const Icon(Icons.edit), label: const Text('Ganti nama'))), // tombol ganti nama
      const Padding(padding: EdgeInsets.fromLTRB(16, 22, 16, 10), child: Text('Lencana Penjelajah', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.greenDark))), // judul koleksi
      const Padding(padding: EdgeInsets.fromLTRB(16, 0, 16, 24), child: AchievementGrid()), // kisi lencana
    ]));
  }
}
