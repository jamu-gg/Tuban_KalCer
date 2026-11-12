import 'package:flutter/material.dart'; // widget dasar Flutter (Color, ThemeData)

/// Palet warna Tuban KalCer, diambil dari logo (siwalan, legen, tenun gedog, klenteng).
class AppColors {
  static const Color green = Color(0xFF1F7A4F); // hijau siwalan: warna utama
  static const Color greenDark = Color(0xFF0E4A31); // hijau tua: bayangan dan judul
  static const Color gold = Color(0xFFEDAA3A); // emas legen: aksen koin dan tombol
  static const Color indigo = Color(0xFF26376B); // indigo gedog: teks dan cincin
  static const Color red = Color(0xFFB8402F); // merah bata: aksen klenteng dan penanda
  static const Color sky = Color(0xFF4FA3D1); // biru laut: peta dan pesisir
  static const Color cream = Color(0xFFFBF4E2); // krem lontar: warna latar
}

/// Tema Material 3 yang dipakai seluruh aplikasi.
class AppTheme {
  static ThemeData get light => ThemeData( // membuat tema terang
        useMaterial3: true, // memakai Material 3
        colorScheme: ColorScheme.fromSeed( // skema warna dari warna dasar
          seedColor: AppColors.green, // warna dasar hijau siwalan
          primary: AppColors.green, // warna utama tombol dan bilah atas
          secondary: AppColors.gold, // warna kedua untuk aksen
          tertiary: AppColors.indigo, // warna ketiga untuk teks penting
          surface: AppColors.cream, // warna permukaan kartu
        ),
        scaffoldBackgroundColor: AppColors.cream, // latar semua layar
        appBarTheme: const AppBarTheme( // gaya bilah atas
          backgroundColor: AppColors.green, // latar hijau
          foregroundColor: Colors.white, // teks dan ikon putih
        ),
        navigationBarTheme: NavigationBarThemeData( // gaya bilah navigasi bawah
          backgroundColor: Colors.white, // latar putih
          indicatorColor: AppColors.gold.withAlpha(90), // penanda tab aktif berwarna emas lembut
        ),
      );
}
