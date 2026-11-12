import 'package:flutter/material.dart'; // widget dasar Flutter
import 'package:provider/provider.dart'; // membaca state dari Provider

import '../../../core/theme/app_theme.dart'; // warna aplikasi
import '../../coin/providers/coin_provider.dart'; // state koin
import '../models/shop_item.dart'; // model dan katalog item
import '../widgets/shop_item_card.dart'; // kartu item

/// Layar Toko Kustomisasi: etalase item gaya Discord Shop dengan kategori bertab.
class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key}); // konstruktor konstan

  /// Judul tab untuk setiap kategori.
  static const Map<ItemCategory, String> _tabNames = { // pemetaan kategori ke judul tab
    ItemCategory.frame: 'Bingkai', // tab bingkai avatar
    ItemCategory.banner: 'Banner', // tab banner
    ItemCategory.theme: 'Tema', // tab warna tema
    ItemCategory.title: 'Gelar', // tab gelar
    ItemCategory.badge: 'Pin', // tab pin
  };

  @override
  Widget build(BuildContext context) { // membangun layar toko
    final coins = context.watch<CoinProvider>().coins; // pantau saldo koin

    return DefaultTabController( // pengendali tab
      length: ItemCategory.values.length, // jumlah tab = jumlah kategori
      child: Scaffold( // kerangka layar
        appBar: AppBar( // bilah atas
          title: const Text('Toko Kustomisasi'), // judul layar
          actions: [ // tombol di kanan bilah atas
            Padding( // jarak untuk chip koin
              padding: const EdgeInsets.only(right: 16), // jarak kanan
              child: Chip( // chip saldo koin
                avatar: const Icon(Icons.monetization_on, color: Color(0xFFFFB300)), // ikon koin
                label: Text('$coins'), // jumlah koin
              ),
            ),
          ],
          bottom: TabBar( // bilah tab kategori
            isScrollable: true, // boleh digeser bila sempit
            tabAlignment: TabAlignment.start, // rata kiri
            labelColor: Colors.white, // PERBAIKAN: teks tab terpilih putih (sebelumnya hijau di atas hijau = hilang)
            unselectedLabelColor: Colors.white70, // teks tab tidak terpilih putih redup
            indicatorColor: AppColors.gold, // garis penanda emas
            indicatorWeight: 3, // ketebalan garis penanda
            dividerColor: Colors.transparent, // hilangkan garis pemisah bawaan M3
            labelStyle: const TextStyle(fontWeight: FontWeight.w700), // tab terpilih lebih tebal
            tabs: [for (final c in ItemCategory.values) Tab(text: _tabNames[c])], // satu tab per kategori
          ),
        ),
        body: TabBarView( // isi tiap tab
          children: [
            for (final c in ItemCategory.values) _CategoryGrid(category: c), // grid item per kategori
          ],
        ),
      ),
    );
  }
}

/// Grid item untuk satu kategori.
class _CategoryGrid extends StatelessWidget {
  final ItemCategory category; // kategori yang ditampilkan
  const _CategoryGrid({required this.category}); // konstruktor

  @override
  Widget build(BuildContext context) { // membangun grid
    final items = shopCatalog.where((i) => i.category == category).toList(); // saring katalog menurut kategori
    return GridView.builder( // grid yang dibangun saat digulir
      padding: const EdgeInsets.all(12), // jarak tepi
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount( // dua kolom
        crossAxisCount: 2, // jumlah kolom
        mainAxisSpacing: 12, // jarak antar baris
        crossAxisSpacing: 12, // jarak antar kolom
        childAspectRatio: 0.74, // rasio lebar : tinggi kartu
      ),
      itemCount: items.length, // jumlah item
      itemBuilder: (_, i) => ShopItemCard(item: items[i]), // bangun kartu
    );
  }
}
