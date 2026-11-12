import 'package:flutter/material.dart'; // widget dasar Flutter
import 'package:provider/provider.dart'; // membaca state dari Provider

import '../../coin/providers/coin_provider.dart'; // state koin
import '../../profile/providers/profile_provider.dart'; // state profil
import '../models/shop_item.dart'; // model item

/// Kumpulan aksi toko yang dipakai bersama oleh kartu item dan lembar pratinjau.
class ShopActions {
  /// Alur pembelian: cek saldo, kurangi koin, simpan inventaris, pasang item. Mengembalikan true bila berhasil.
  static Future<bool> buy(BuildContext context, ShopItem item) async { // proses beli
    final coin = context.read<CoinProvider>(); // ambil penyedia koin (tanpa memantau)
    final profile = context.read<ProfileProvider>(); // ambil penyedia profil
    final messenger = ScaffoldMessenger.of(context); // untuk menampilkan SnackBar setelah proses async
    final ok = await coin.spendCoins(item.price); // coba kurangi koin
    if (!ok) { // saldo tidak cukup
      messenger.showSnackBar(SnackBar(content: Text('Koin tidak cukup. Butuh ${item.price} koin.'))); // beri tahu pengguna
      return false; // gagal
    }
    await profile.addPurchasedItem(item); // simpan ke inventaris dan pasang
    await profile.refreshProfile(); // sinkronkan saldo di kartu profil
    messenger.showSnackBar(SnackBar(content: Text('${item.name} berhasil dibeli dan dipakai!'))); // pesan sukses
    return true; // berhasil
  }
}
