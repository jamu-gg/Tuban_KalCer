import 'package:flutter/material.dart'; // widget dasar Flutter
import 'package:provider/provider.dart'; // membaca state dari Provider

import '../../coin/providers/coin_provider.dart'; // saldo koin
import '../../profile/widgets/discord_profile_card.dart'; // kartu profil untuk pratinjau langsung
import '../models/shop_item.dart'; // model item
import 'rarity_badge.dart'; // lencana rarity
import 'shop_action_button.dart'; // tombol aksi

/// Membuka lembar bawah yang memperlihatkan item langsung di kartu profil pengguna.
void showPreviewSheet(BuildContext hostContext, ShopItem item) { // fungsi pembuka
  showModalBottomSheet( // lembar dari bawah layar
    context: hostContext, // konteks layar toko
    isScrollControlled: true, // tinggi menyesuaikan isi
    backgroundColor: const Color(0xFF1E1F22), // latar gelap
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))), // sudut atas membulat
    builder: (sheetContext) => _PreviewBody(item: item, hostContext: hostContext), // isi lembar
  );
}

class _PreviewBody extends StatelessWidget {
  final ShopItem item; // item yang dipratinjau
  final BuildContext hostContext; // konteks layar toko yang tetap hidup
  const _PreviewBody({required this.item, required this.hostContext}); // konstruktor

  @override
  Widget build(BuildContext context) { // membangun isi lembar
    final coins = context.watch<CoinProvider>().coins; // pantau saldo
    final kurang = item.price - coins; // kekurangan koin (negatif bila cukup)
    return SafeArea( // hindari area sistem
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16), // jarak dalam
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)))), // pegangan lembar
          const SizedBox(height: 14), // jarak
          Row(children: [
            Expanded(child: Text(item.name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800))), // nama item
            RarityBadge(rarity: item.rarity), // lencana rarity
          ]),
          const SizedBox(height: 6), // jarak
          Text(item.description, style: const TextStyle(color: Colors.white70, fontSize: 13)), // keterangan
          const SizedBox(height: 14), // jarak
          ClipRRect(borderRadius: BorderRadius.circular(16), child: DiscordProfileCard(preview: item)), // pratinjau langsung di profil
          const SizedBox(height: 12), // jarak
          if (kurang > 0) // info bila koin kurang
            Padding(
              padding: const EdgeInsets.only(bottom: 8), // jarak bawah
              child: Text('Kurang $kurang koin lagi untuk membelinya.', style: const TextStyle(color: Color(0xFFFFB74D), fontSize: 12)), // pesan kekurangan
            ),
          SizedBox(
            width: double.infinity, // tombol selebar lembar
            child: ShopActionButton(item: item, hostContext: hostContext, beforeAction: () => Navigator.of(context).pop()), // aksi, tutup lembar dulu
          ),
        ]),
      ),
    );
  }
}
