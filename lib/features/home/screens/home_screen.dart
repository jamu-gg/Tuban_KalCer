import 'package:flutter/material.dart'; // widget dasar Flutter

import '../../games/screens/games_tab.dart'; // tab game
import '../../map/screens/map_screen.dart'; // layar peta
import '../../profile/screens/profile_tab.dart'; // tab profil
import '../../shop/screens/shop_screen.dart'; // layar toko
import 'dashboard_tab.dart'; // tab beranda

/// Kerangka layar utama: lima tab (Beranda, Peta, Game, Toko, Profil).
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key}); // konstruktor konstan

  @override
  State<HomeScreen> createState() => _HomeScreenState(); // buat state
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0; // tab yang sedang aktif

  @override
  Widget build(BuildContext context) { // membangun layar utama
    return Scaffold(
      body: IndexedStack( // tampilkan satu tab, simpan state tab lain
        index: _index, // tab aktif
        children: [
          DashboardTab(onGoTo: (i) => setState(() => _index = i)), // tab 0: beranda
          const MapScreen(), // tab 1: peta
          const GamesTab(), // tab 2: mini games
          const ShopScreen(), // tab 3: toko
          const ProfileTab(), // tab 4: profil
        ],
      ),
      bottomNavigationBar: NavigationBar( // bilah navigasi bawah
        selectedIndex: _index, // tab terpilih
        onDestinationSelected: (i) => setState(() => _index = i), // ganti tab
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Beranda'), // tab beranda
          NavigationDestination(icon: Icon(Icons.map_outlined), selectedIcon: Icon(Icons.map), label: 'Peta'), // tab peta
          NavigationDestination(icon: Icon(Icons.sports_esports_outlined), selectedIcon: Icon(Icons.sports_esports), label: 'Game'), // tab game
          NavigationDestination(icon: Icon(Icons.storefront_outlined), selectedIcon: Icon(Icons.storefront), label: 'Toko'), // tab toko
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profil'), // tab profil
        ],
      ),
    );
  }
}
