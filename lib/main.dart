import 'package:flutter/material.dart'; // widget dasar Flutter
import 'package:provider/provider.dart'; // state management

import 'core/database/db_init.dart'; // memilih mesin database sesuai platform (web atau mobile)
import 'core/theme/app_theme.dart'; // tema warna Tuban KalCer
import 'features/achievements/providers/achievement_provider.dart'; // state lencana
import 'features/coin/providers/coin_provider.dart'; // state koin
import 'features/home/screens/splash_screen.dart'; // layar pembuka
import 'features/profile/providers/profile_provider.dart'; // state profil

Future<void> main() async { // titik awal aplikasi
  WidgetsFlutterBinding.ensureInitialized(); // wajib sebelum memakai plugin (sqflite)
  initDatabaseFactory(); // di web: pakai SQLite web; di Android/iOS: tidak melakukan apa-apa
  final coinProvider = CoinProvider(); // buat penyedia koin
  final profileProvider = ProfileProvider(); // buat penyedia profil
  final achievementProvider = AchievementProvider(); // buat penyedia lencana
  await coinProvider.load(); // muat koin dari SQLite
  await achievementProvider.load(); // muat lencana dari SQLite
  await profileProvider.load(); // muat profil dan inventaris dari SQLite
  runApp( // jalankan aplikasi
    MultiProvider( // daftarkan beberapa penyedia state sekaligus
      providers: [
        ChangeNotifierProvider.value(value: coinProvider), // sediakan CoinProvider ke seluruh widget
        ChangeNotifierProvider.value(value: profileProvider), // sediakan ProfileProvider ke seluruh widget
        ChangeNotifierProvider.value(value: achievementProvider), // sediakan AchievementProvider ke seluruh widget
      ],
      child: const TubanKalCerApp(), // widget akar aplikasi
    ),
  );
}

/// Widget akar aplikasi.
class TubanKalCerApp extends StatelessWidget {
  const TubanKalCerApp({super.key}); // konstruktor konstan

  @override
  Widget build(BuildContext context) { // membangun aplikasi
    return MaterialApp( // aplikasi bergaya Material
      title: 'Tuban KalCer', // judul aplikasi
      debugShowCheckedModeBanner: false, // sembunyikan pita debug
      theme: AppTheme.light, // pakai tema warna Tuban KalCer
      home: const SplashScreen(), // layar pertama: splash lalu beranda
    );
  }
}
