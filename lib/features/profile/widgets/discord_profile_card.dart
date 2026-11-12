import 'package:flutter/material.dart'; // widget dasar Flutter
import 'package:provider/provider.dart'; // membaca state dari Provider

import '../../coin/providers/coin_provider.dart'; // saldo koin terbaru
import '../../shop/models/shop_item.dart'; // katalog dan model item
import '../providers/profile_provider.dart'; // state profil

/// Kartu profil gaya Discord: banner, bingkai avatar, gelar, pin, dan warna tema.
class DiscordProfileCard extends StatelessWidget {
  final ShopItem? preview; // item yang dipratinjau (menimpa item terpasang pada kategorinya); null = tampilan asli
  const DiscordProfileCard({super.key, this.preview}); // konstruktor konstan

  @override
  Widget build(BuildContext context) { // membangun tampilan kartu
    final profile = context.watch<ProfileProvider>().profile; // pantau perubahan profil
    final coins = context.watch<CoinProvider>().coins; // pantau saldo koin (selalu terbaru)
    // Pilih item pratinjau bila kategorinya cocok, jika tidak pakai item yang terpasang.
    ShopItem? pick(ItemCategory c, String? equippedId) => // fungsi bantu pemilih item
        (preview != null && preview!.category == c) ? preview : findItem(equippedId); // pratinjau menang
    final frame = pick(ItemCategory.frame, profile.frameId); // bingkai (bisa null)
    final banner = pick(ItemCategory.banner, profile.bannerId); // banner
    final theme = pick(ItemCategory.theme, profile.themeId); // tema
    final title = pick(ItemCategory.title, profile.titleId); // gelar
    final badge = pick(ItemCategory.badge, profile.badgeId); // pin

    // Warna badan kartu: gradasi tema bila ada, jika tidak abu-abu gelap bawaan.
    final bodyColors = theme == null // cek apakah ada tema
        ? [const Color(0xFF2B2D31), const Color(0xFF1E1F22)] // warna bawaan
        : [theme.primary, theme.secondary.withAlpha(140)]; // warna dari tema

    return Container( // wadah luar kartu
      margin: EdgeInsets.all(preview == null ? 16 : 0), // jarak dari tepi layar (tanpa jarak saat pratinjau)
      clipBehavior: Clip.antiAlias, // potong isi mengikuti sudut membulat
      decoration: BoxDecoration( // hiasan kartu
        borderRadius: BorderRadius.circular(16), // sudut membulat
        gradient: LinearGradient( // gradasi warna badan kartu
          begin: Alignment.topCenter, // mulai dari atas
          end: Alignment.bottomCenter, // berakhir di bawah
          colors: bodyColors, // daftar warna gradasi
        ),
      ),
      child: Column( // susun banner dan isi secara vertikal
        crossAxisAlignment: CrossAxisAlignment.start, // rata kiri
        children: [
          // ---------- BANNER + AVATAR ----------
          Stack( // tumpuk avatar di atas banner
            clipBehavior: Clip.none, // izinkan avatar keluar dari area banner
            children: [
              Container( // area banner
                height: 110, // tinggi banner
                width: double.infinity, // selebar kartu
                decoration: BoxDecoration( // hiasan banner
                  gradient: LinearGradient( // gradasi banner
                    colors: banner == null // cek apakah ada banner
                        ? [const Color(0xFF5865F2), const Color(0xFF404EED)] // banner bawaan ungu Discord
                        : [banner.primary, banner.secondary], // warna dari item banner
                  ),
                ),
              ),
              Positioned( // posisi avatar
                left: 16, // jarak dari kiri
                bottom: -40, // setengah avatar menjorok ke bawah banner
                child: _Avatar(frameColor: frame?.primary), // avatar dengan bingkai
              ),
            ],
          ),
          const SizedBox(height: 48), // ruang agar tidak tertutup avatar
          Padding( // isi teks kartu
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16), // jarak dalam
            child: Column( // susun teks secara vertikal
              crossAxisAlignment: CrossAxisAlignment.start, // rata kiri
              children: [
                Row( // baris nama dan pin
                  children: [
                    Text( // nama pengguna
                      profile.name, // isi nama
                      style: const TextStyle( // gaya teks nama
                        color: Colors.white, // warna putih
                        fontSize: 22, // ukuran huruf
                        fontWeight: FontWeight.bold, // tebal
                      ),
                    ),
                    const SizedBox(width: 8), // jarak nama dan pin
                    if (badge != null) // tampilkan pin hanya bila ada
                      Tooltip( // keterangan saat pin ditekan lama
                        message: badge.name, // nama pin
                        child: Icon(badge.icon, color: badge.primary, size: 22), // ikon pin
                      ),
                  ],
                ),
                if (title != null) ...[ // tampilkan gelar hanya bila ada
                  const SizedBox(height: 6), // jarak vertikal
                  Container( // label gelar
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), // jarak dalam label
                    decoration: BoxDecoration( // hiasan label
                      color: Colors.black.withAlpha(90), // latar gelap transparan
                      borderRadius: BorderRadius.circular(20), // bentuk pil
                      border: Border.all(color: title.primary), // garis tepi warna gelar
                    ),
                    child: Text( // teks gelar
                      title.text ?? title.name, // isi gelar
                      style: TextStyle(color: title.primary, fontSize: 12, fontWeight: FontWeight.w600), // gaya teks gelar
                    ),
                  ),
                ],
                const SizedBox(height: 12), // jarak vertikal
                Container( // kotak informasi koin
                  padding: const EdgeInsets.all(12), // jarak dalam kotak
                  decoration: BoxDecoration( // hiasan kotak
                    color: Colors.black.withAlpha(77), // latar gelap transparan
                    borderRadius: BorderRadius.circular(10), // sudut membulat
                  ),
                  child: Row( // ikon koin dan jumlah
                    children: [
                      const Icon(Icons.monetization_on, color: Color(0xFFFFD54F)), // ikon koin emas
                      const SizedBox(width: 8), // jarak ikon dan teks
                      Text( // jumlah koin
                        '$coins KalCer Coins', // teks saldo
                        style: const TextStyle(color: Colors.white, fontSize: 15), // gaya teks
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Avatar bulat dengan bingkai (avatar decoration) berpendar.
class _Avatar extends StatelessWidget {
  final Color? frameColor; // warna bingkai; null berarti tanpa bingkai
  const _Avatar({this.frameColor}); // konstruktor

  @override
  Widget build(BuildContext context) { // membangun avatar
    return Container( // lingkaran bingkai
      padding: const EdgeInsets.all(4), // ketebalan bingkai
      decoration: BoxDecoration( // hiasan bingkai
        shape: BoxShape.circle, // berbentuk lingkaran
        color: frameColor ?? const Color(0xFF1E1F22), // warna bingkai atau warna bawaan
        boxShadow: frameColor == null // cek ada tidaknya bingkai
            ? null // tanpa bayangan jika tidak ada bingkai
            : [BoxShadow(color: frameColor!.withAlpha(204), blurRadius: 14, spreadRadius: 2)], // efek berpendar
      ),
      child: const CircleAvatar( // foto profil
        radius: 38, // ukuran avatar
        backgroundColor: Color(0xFF3B3D44), // warna latar avatar
        child: Icon(Icons.person, size: 42, color: Colors.white70), // ikon orang sebagai foto sementara
      ),
    );
  }
}
