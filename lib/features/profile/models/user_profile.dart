/// Model data profil pengguna yang disimpan di tabel `profile`.
class UserProfile {
  final String name; // nama pengguna
  final int coins; // jumlah KalCer Coins
  final String? frameId; // id bingkai avatar yang dipakai
  final String? bannerId; // id banner yang dipakai
  final String? themeId; // id tema warna yang dipakai
  final String? titleId; // id gelar yang dipakai
  final String? badgeId; // id pin yang dipakai

  const UserProfile({ // konstruktor konstan
    required this.name, // nama wajib
    required this.coins, // koin wajib
    this.frameId, // bingkai opsional
    this.bannerId, // banner opsional
    this.themeId, // tema opsional
    this.titleId, // gelar opsional
    this.badgeId, // pin opsional
  });

  /// Membuat objek dari satu baris hasil query SQLite.
  factory UserProfile.fromMap(Map<String, Object?> map) => UserProfile( // pabrik dari Map
        name: map['name'] as String, // ambil kolom name
        coins: map['coins'] as int, // ambil kolom coins
        frameId: map['frame_id'] as String?, // ambil kolom frame_id
        bannerId: map['banner_id'] as String?, // ambil kolom banner_id
        themeId: map['theme_id'] as String?, // ambil kolom theme_id
        titleId: map['title_id'] as String?, // ambil kolom title_id
        badgeId: map['badge_id'] as String?, // ambil kolom badge_id
      );
}
