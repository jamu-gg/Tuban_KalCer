import 'package:path/path.dart'; // untuk menyusun lokasi file database
import 'package:sqflite/sqflite.dart'; // pustaka SQLite untuk Flutter

import '../../features/profile/models/user_profile.dart'; // model profil pengguna

/// Kelas pembantu akses database SQLite (pola Singleton).
/// Menyimpan: profil + koin, inventaris item yang dibeli, dan status game.
class DatabaseHelper {
  DatabaseHelper._internal(); // konstruktor privat agar tidak bisa dibuat dari luar
  static final DatabaseHelper instance = DatabaseHelper._internal(); // satu-satunya objek yang dipakai bersama

  static Database? _database; // penampung koneksi database (null sebelum dibuka)

  /// Mengambil database; jika belum dibuka maka dibuka terlebih dahulu.
  Future<Database> get database async { // getter asinkron
    if (_database != null) return _database!; // pakai koneksi yang sudah ada
    _database = await _initDb(); // buka database baru
    return _database!; // kembalikan koneksi
  }

  /// Membuka (atau membuat) file database di penyimpanan perangkat.
  Future<Database> _initDb() async { // inisialisasi database
    final dbPath = await getDatabasesPath(); // lokasi folder database di perangkat
    final path = join(dbPath, 'tuban_kalcer.db'); // gabungkan folder dan nama file
    return openDatabase( // buka database
      path, // lokasi file
      version: 1, // versi skema database
      onCreate: _onCreate, // dipanggil saat database pertama kali dibuat
    );
  }

  /// Membuat seluruh tabel dan mengisi profil awal.
  Future<void> _onCreate(Database db, int version) async { // pembuatan skema
    await db.execute('''
      CREATE TABLE profile (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        coins INTEGER NOT NULL DEFAULT 0,
        frame_id TEXT,
        banner_id TEXT,
        theme_id TEXT,
        title_id TEXT,
        badge_id TEXT
      )
    '''); // tabel profil: nama, koin, dan item yang sedang dipakai
    await db.execute('''
      CREATE TABLE inventory (
        item_id TEXT PRIMARY KEY,
        category TEXT NOT NULL
      )
    '''); // tabel inventaris: item yang sudah dibeli (id unik)
    await db.execute('''
      CREATE TABLE game_state (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    '''); // tabel status game: pasangan kunci-nilai (skor tertinggi, materi selesai, dll.)
    await db.insert('profile', { // isi satu baris profil awal
      'id': 1, // hanya ada satu profil, id = 1
      'name': 'Warga Tuban', // nama bawaan
      'coins': 500, // koin awal agar toko bisa dicoba
    });
  }

  // ===================== PROFIL & KOIN =====================

  /// Membaca profil pengguna (baris id = 1).
  Future<UserProfile> getProfile() async { // ambil profil
    final db = await database; // pastikan database terbuka
    final rows = await db.query('profile', where: 'id = ?', whereArgs: [1]); // cari baris id 1
    return UserProfile.fromMap(rows.first); // ubah baris menjadi objek profil
  }

  /// Mengubah jumlah koin menjadi nilai baru.
  Future<void> updateCoins(int newCoins) async { // simpan koin
    final db = await database; // pastikan database terbuka
    await db.update('profile', {'coins': newCoins}, where: 'id = ?', whereArgs: [1]); // perbarui kolom coins
  }

  /// Mengubah nama pengguna.
  Future<void> updateName(String name) async { // simpan nama
    final db = await database; // pastikan database terbuka
    await db.update('profile', {'name': name}, where: 'id = ?', whereArgs: [1]); // perbarui kolom name
  }

  /// Memasang item pada profil. [column] salah satu dari: frame_id, banner_id, theme_id, title_id, badge_id.
  Future<void> equipItem(String column, String? itemId) async { // pasang item
    final db = await database; // pastikan database terbuka
    await db.update('profile', {column: itemId}, where: 'id = ?', whereArgs: [1]); // perbarui kolom item
  }

  // ===================== INVENTARIS =====================

  /// Menyimpan item yang baru dibeli ke inventaris.
  Future<void> addInventory(String itemId, String category) async { // tambah inventaris
    final db = await database; // pastikan database terbuka
    await db.insert( // sisipkan baris baru
      'inventory', // nama tabel
      {'item_id': itemId, 'category': category}, // data baris
      conflictAlgorithm: ConflictAlgorithm.ignore, // abaikan jika item sudah dimiliki
    );
  }

  /// Mengambil daftar id item yang sudah dimiliki.
  Future<Set<String>> getOwnedItemIds() async { // baca inventaris
    final db = await database; // pastikan database terbuka
    final rows = await db.query('inventory'); // ambil semua baris inventaris
    return rows.map((r) => r['item_id'] as String).toSet(); // kumpulkan id menjadi Set
  }

  // ===================== STATUS GAME =====================

  /// Menyimpan status game (misalnya skor tertinggi) dengan kunci tertentu.
  Future<void> setGameState(String key, String value) async { // simpan status
    final db = await database; // pastikan database terbuka
    await db.insert( // sisipkan atau timpa
      'game_state', // nama tabel
      {'key': key, 'value': value}, // data baris
      conflictAlgorithm: ConflictAlgorithm.replace, // timpa jika kunci sudah ada
    );
  }

  /// Membaca status game berdasarkan kunci; null jika belum ada.
  Future<String?> getGameState(String key) async { // baca status
    final db = await database; // pastikan database terbuka
    final rows = await db.query('game_state', where: 'key = ?', whereArgs: [key]); // cari berdasarkan kunci
    if (rows.isEmpty) return null; // belum pernah disimpan
    return rows.first['value'] as String; // kembalikan nilainya
  }

  /// Membaca semua status game yang kuncinya diawali [prefix] (contoh: 'ach_' untuk lencana). Mengembalikan peta kunci -> nilai.
  Future<Map<String, String>> getGameStatesByPrefix(String prefix) async { // baca banyak status sekaligus
    final db = await database; // pastikan database terbuka
    final rows = await db.query('game_state', where: "substr(key, 1, ?) = ?", whereArgs: [prefix.length, prefix]); // cocokkan awalan kunci tanpa wildcard LIKE
    return {for (final r in rows) r['key'] as String: r['value'] as String}; // ubah baris menjadi peta
  }

  /// Menghapus satu status game (dipakai untuk melepas penanda favorit).
  Future<void> deleteGameState(String key) async { // hapus status
    final db = await database; // pastikan database terbuka
    await db.delete('game_state', where: 'key = ?', whereArgs: [key]); // hapus baris berkunci tersebut
  }
}
