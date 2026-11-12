import 'package:flutter/foundation.dart'; // ChangeNotifier

import '../../../core/database/database_helper.dart'; // akses SQLite
import '../models/achievement.dart'; // model lencana

/// Menyimpan lencana yang sudah dibuka. Disimpan di tabel game_state dengan kunci 'ach_<id>'.
class AchievementProvider extends ChangeNotifier {
  Set<String> _unlocked = {}; // id lencana yang sudah terbuka

  Set<String> get unlocked => _unlocked; // getter untuk UI
  int get count => _unlocked.length; // jumlah lencana terbuka
  bool isUnlocked(String id) => _unlocked.contains(id); // cek satu lencana

  /// Memuat lencana dari database (dipanggil sekali saat aplikasi mulai).
  Future<void> load() async { // muat data
    final rows = await DatabaseHelper.instance.getGameStatesByPrefix('ach_'); // baca semua kunci berawalan ach_
    _unlocked = rows.keys.map((k) => k.substring(4)).toSet(); // buang awalan untuk mendapat id
    notifyListeners(); // perbarui UI
  }

  /// Membuka satu lencana. Mengembalikan lencana tersebut bila BARU terbuka, null bila sudah dimiliki.
  Future<Achievement?> unlock(String id) async { // buka lencana
    if (_unlocked.contains(id)) return null; // sudah terbuka, abaikan
    final a = findAchievement(id); // cari data lencana
    if (a == null) return null; // id tidak dikenal
    await DatabaseHelper.instance.setGameState('ach_$id', '1'); // simpan ke database
    _unlocked = {..._unlocked, id}; // perbarui himpunan lokal
    notifyListeners(); // perbarui UI
    return a; // beri tahu pemanggil
  }

  /// Memeriksa lencana jelajah berdasarkan kumpulan lokasi yang sudah selesai; mengembalikan yang baru terbuka.
  Future<List<Achievement>> evaluateExploration(Set<String> doneIds) async { // evaluasi jelajah
    final fresh = <Achievement>[]; // hasil lencana baru
    for (final a in achievementList) { // telusuri semua lencana
      if (a.group != AchievementGroup.jelajah) continue; // hanya kelompok jelajah
      final byPois = a.poiIds.isNotEmpty && a.poiIds.every(doneIds.contains); // semua lokasi syarat selesai?
      final byCount = a.minPois > 0 && doneIds.length >= a.minPois; // jumlah lokasi cukup?
      if (byPois || byCount) { // syarat terpenuhi
        final got = await unlock(a.id); // coba buka
        if (got != null) fresh.add(got); // catat bila baru
      }
    }
    return fresh; // kembalikan daftar baru
  }
}
