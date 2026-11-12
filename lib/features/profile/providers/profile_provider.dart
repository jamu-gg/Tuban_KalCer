import 'package:flutter/foundation.dart'; // ChangeNotifier untuk state management

import '../../../core/database/database_helper.dart'; // akses database SQLite
import '../../shop/models/shop_item.dart'; // model item toko
import '../models/user_profile.dart'; // model profil pengguna

/// Mengelola profil pengguna, inventaris item, dan item yang sedang dipakai.
class ProfileProvider extends ChangeNotifier {
  UserProfile _profile = const UserProfile(name: 'Warga Tuban', coins: 0); // profil sementara sebelum data dimuat
  Set<String> _owned = {}; // kumpulan id item yang sudah dimiliki

  UserProfile get profile => _profile; // getter profil untuk UI
  Set<String> get owned => _owned; // getter inventaris untuk UI

  /// Memuat profil dan inventaris dari database.
  Future<void> load() async { // muat data
    _profile = await DatabaseHelper.instance.getProfile(); // baca profil
    _owned = await DatabaseHelper.instance.getOwnedItemIds(); // baca inventaris
    notifyListeners(); // perbarui UI
  }

  /// Apakah item sudah dimiliki pengguna?
  bool isOwned(String itemId) => _owned.contains(itemId); // cek di inventaris

  /// Apakah item sedang dipakai di profil?
  bool isEquipped(ShopItem item) => // cek item terpasang
      _equippedIdFor(item.category) == item.id; // bandingkan id terpasang dengan id item

  /// Menambahkan item yang baru dibeli ke inventaris, lalu langsung memasangnya.
  Future<void> addPurchasedItem(ShopItem item) async { // simpan pembelian
    await DatabaseHelper.instance.addInventory(item.id, item.category.name); // simpan ke tabel inventory
    _owned = {..._owned, item.id}; // perbarui Set lokal
    await equip(item); // pasang otomatis setelah dibeli
  }

  /// Memasang item pada kartu profil (mengganti item lama di kategori yang sama).
  Future<void> equip(ShopItem item) async { // pasang item
    final column = _columnFor(item.category); // tentukan kolom database
    await DatabaseHelper.instance.equipItem(column, item.id); // simpan ke database
    _profile = await DatabaseHelper.instance.getProfile(); // baca ulang profil terbaru
    notifyListeners(); // perbarui UI
  }

  /// Melepas item pada kategori tertentu.
  Future<void> unequip(ItemCategory category) async { // lepas item
    await DatabaseHelper.instance.equipItem(_columnFor(category), null); // kosongkan kolom
    _profile = await DatabaseHelper.instance.getProfile(); // baca ulang profil terbaru
    notifyListeners(); // perbarui UI
  }

  /// Menyinkronkan saldo koin ke objek profil (dipanggil setelah koin berubah).
  Future<void> refreshProfile() async { // muat ulang profil
    _profile = await DatabaseHelper.instance.getProfile(); // baca profil terbaru
    notifyListeners(); // perbarui UI
  }

  /// Menerjemahkan kategori menjadi nama kolom di tabel profile.
  String _columnFor(ItemCategory c) { // pemetaan kategori ke kolom
    switch (c) { // pilih berdasarkan kategori
      case ItemCategory.frame: // bingkai avatar
        return 'frame_id'; // kolom bingkai
      case ItemCategory.banner: // banner profil
        return 'banner_id'; // kolom banner
      case ItemCategory.theme: // warna tema
        return 'theme_id'; // kolom tema
      case ItemCategory.title: // gelar
        return 'title_id'; // kolom gelar
      case ItemCategory.badge: // pin
        return 'badge_id'; // kolom pin
    }
  }

  /// Mengambil id item yang terpasang untuk suatu kategori.
  String? _equippedIdFor(ItemCategory c) { // baca id terpasang
    switch (c) { // pilih berdasarkan kategori
      case ItemCategory.frame: // bingkai avatar
        return _profile.frameId; // id bingkai
      case ItemCategory.banner: // banner profil
        return _profile.bannerId; // id banner
      case ItemCategory.theme: // warna tema
        return _profile.themeId; // id tema
      case ItemCategory.title: // gelar
        return _profile.titleId; // id gelar
      case ItemCategory.badge: // pin
        return _profile.badgeId; // id pin
    }
  }

  /// Mengubah nama pengguna dan menyimpannya ke database.
  Future<void> updateName(String name) async { // ubah nama
    final clean = name.trim(); // buang spasi di tepi
    if (clean.isEmpty) return; // abaikan nama kosong
    await DatabaseHelper.instance.updateName(clean); // simpan ke database
    _profile = await DatabaseHelper.instance.getProfile(); // baca ulang profil terbaru
    notifyListeners(); // perbarui UI
  }
}
