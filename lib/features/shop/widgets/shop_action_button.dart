import 'package:flutter/material.dart'; // widget dasar Flutter
import 'package:provider/provider.dart'; // membaca state dari Provider

import '../../profile/providers/profile_provider.dart'; // state profil
import '../controllers/shop_actions.dart'; // aksi beli
import '../models/shop_item.dart'; // model item

/// Tombol aksi item: berubah menjadi Beli, Pakai, atau Lepas sesuai status item.
class ShopActionButton extends StatelessWidget {
  final ShopItem item; // item yang dikendalikan
  final BuildContext hostContext; // konteks layar induk yang tetap hidup (untuk SnackBar)
  final VoidCallback? beforeAction; // dijalankan sebelum aksi (misalnya menutup lembar pratinjau)
  const ShopActionButton({super.key, required this.item, required this.hostContext, this.beforeAction}); // konstruktor

  @override
  Widget build(BuildContext context) { // membangun tombol
    final profile = context.watch<ProfileProvider>(); // pantau perubahan profil
    final owned = profile.isOwned(item.id); // sudah dimiliki?
    final equipped = profile.isEquipped(item); // sedang dipakai?

    if (equipped) { // sedang dipakai: tawarkan Lepas
      return OutlinedButton( // tombol berbingkai
        onPressed: () { beforeAction?.call(); profile.unequip(item.category); }, // tutup lembar lalu lepas item
        child: const Text('Lepas'), // teks tombol
      );
    }
    if (owned) { // dimiliki tapi belum dipakai: tawarkan Pakai
      return FilledButton( // tombol terisi
        onPressed: () { beforeAction?.call(); profile.equip(item); }, // tutup lembar lalu pasang item
        child: const Text('Pakai'), // teks tombol
      );
    }
    return FilledButton.icon( // belum dimiliki: tawarkan Beli
      onPressed: () { beforeAction?.call(); ShopActions.buy(hostContext, item); }, // tutup lembar lalu beli memakai konteks induk
      icon: const Icon(Icons.monetization_on, size: 16), // ikon koin
      label: Text('${item.price}'), // harga
    );
  }
}
