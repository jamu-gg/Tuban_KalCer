import 'package:flutter/material.dart'; // widget dasar Flutter

import '../../../core/theme/app_theme.dart'; // warna aplikasi
import 'home_screen.dart'; // layar tujuan setelah splash

/// Layar pembuka: logo Tuban KalCer selama 2 detik, lalu masuk ke beranda.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key}); // konstruktor konstan

  @override
  State<SplashScreen> createState() => _SplashScreenState(); // buat state
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() { // dipanggil sekali saat layar dibuat
    super.initState(); // panggil induk
    Future.delayed(const Duration(seconds: 2), () { // tunggu 2 detik
      if (!mounted) return; // batalkan bila layar sudah ditutup
      Navigator.of(context).pushReplacement( // ganti layar (splash tidak bisa dikembalikan)
        MaterialPageRoute(builder: (_) => const HomeScreen()), // tujuan: layar utama
      );
    });
  }

  @override
  Widget build(BuildContext context) { // membangun tampilan splash
    return Scaffold( // kerangka layar
      body: Container( // latar gradasi hijau
        decoration: const BoxDecoration(
          gradient: LinearGradient( // gradasi diagonal
            begin: Alignment.topLeft, // mulai dari kiri atas
            end: Alignment.bottomRight, // berakhir di kanan bawah
            colors: [AppColors.green, AppColors.greenDark], // hijau siwalan ke hijau tua
          ),
        ),
        child: Center( // letakkan isi di tengah
          child: Column( // susun vertikal
            mainAxisSize: MainAxisSize.min, // tinggi mengikuti isi
            children: [
              Image.asset('assets/images/logo.png', width: 170), // logo aplikasi
              const SizedBox(height: 18), // jarak
              const Text('TUBAN KALCER', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: 2)), // nama aplikasi
              const SizedBox(height: 8), // jarak
              const Text('JELAJAH BUDAYA · RAIH KOIN', style: TextStyle(color: AppColors.gold, fontSize: 11, letterSpacing: 4)), // tagline
            ],
          ),
        ),
      ),
    );
  }
}
