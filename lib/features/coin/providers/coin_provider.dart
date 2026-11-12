import 'package:flutter/foundation.dart'; // ChangeNotifier untuk state management

import '../../../core/database/database_helper.dart'; // akses database SQLite

/// Mengelola saldo KalCer Coins dan menyimpannya ke SQLite.
class CoinProvider extends ChangeNotifier {
  int _coins = 0; // saldo koin saat ini (privat)
  bool _loaded = false; // penanda data sudah dimuat dari database

  int get coins => _coins; // getter agar UI bisa membaca saldo
  bool get loaded => _loaded; // getter status pemuatan

  /// Memuat saldo koin dari database (dipanggil sekali saat aplikasi mulai).
  Future<void> load() async { // muat data
    final profile = await DatabaseHelper.instance.getProfile(); // baca profil
    _coins = profile.coins; // salin saldo ke state
    _loaded = true; // tandai selesai dimuat
    notifyListeners(); // beri tahu UI agar menggambar ulang
  }

  /// Menambah koin (hadiah materi, kuis, atau game ketangkasan).
  Future<void> addCoins(int amount) async { // tambah koin
    if (amount <= 0) return; // abaikan jumlah tidak valid
    _coins += amount; // tambahkan ke saldo
    await DatabaseHelper.instance.updateCoins(_coins); // simpan ke database
    notifyListeners(); // perbarui UI
  }

  /// Mengurangi koin untuk pembelian. Mengembalikan true jika saldo cukup.
  Future<bool> spendCoins(int amount) async { // belanja koin
    if (amount <= 0 || _coins < amount) return false; // gagal jika saldo kurang
    _coins -= amount; // kurangi saldo
    await DatabaseHelper.instance.updateCoins(_coins); // simpan ke database
    notifyListeners(); // perbarui UI
    return true; // pembelian berhasil
  }

  /// Memberi hadiah membaca Story Card; hanya sekali per lokasi. Mengembalikan true jika hadiah diberikan.
  Future<bool> claimStoryReward(String poiId, int amount) async { // klaim hadiah materi
    final key = 'story_$poiId'; // kunci status di tabel game_state
    final sudah = await DatabaseHelper.instance.getGameState(key); // cek apakah sudah pernah diklaim
    if (sudah != null) return false; // sudah diklaim, tidak ada hadiah lagi
    await DatabaseHelper.instance.setGameState(key, '1'); // tandai sudah diklaim
    await addCoins(amount); // tambahkan koin hadiah
    return true; // hadiah diberikan
  }

  /// Apakah materi lokasi ini sudah pernah diklaim hadiahnya?
  Future<bool> isStoryClaimed(String poiId) async { // cek status klaim
    final v = await DatabaseHelper.instance.getGameState('story_$poiId'); // baca status
    return v != null; // true jika sudah ada
  }

  /// Bonus koin kuis untuk jawaban benar berturut-turut: 0 jika streak < 3, lalu +5 per soal tambahan.
  int comboBonus(int streak) { // hitung bonus combo
    if (streak < 3) return 0; // belum mencapai combo
    return (streak - 2) * 5; // streak 3 = +5, 4 = +10, dst.
  }
}
