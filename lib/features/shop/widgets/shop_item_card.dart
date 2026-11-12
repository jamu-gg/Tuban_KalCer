import 'package:flutter/material.dart'; // widget dasar Flutter
import 'package:provider/provider.dart'; // membaca state dari Provider

import '../../profile/providers/profile_provider.dart'; // status kepemilikan item
import '../models/shop_item.dart'; // model item
import 'item_preview_art.dart'; // gambar pratinjau item
import 'preview_sheet.dart'; // lembar pratinjau langsung
import 'rarity_badge.dart'; // lencana kelangkaan
import 'shop_action_button.dart'; // tombol beli/pakai/lepas

/// Kartu satu item gaya Discord Shop: gambar, lencana rarity, nama, tombol pratinjau dan aksi.
class ShopItemCard extends StatelessWidget {
  final ShopItem item; // item yang ditampilkan
  const ShopItemCard({super.key, required this.item}); // konstruktor

  @override
  Widget build(BuildContext context) { // membangun kartu
    final profile = context.watch<ProfileProvider>(); // pantau status item
    final equipped = profile.isEquipped(item); // sedang dipakai?
    final owned = profile.isOwned(item.id); // sudah dimiliki?

    return Container( // wadah kartu
      clipBehavior: Clip.antiAlias, // potong isi mengikuti sudut
      decoration: BoxDecoration( // hiasan kartu
        color: const Color(0xFF2B2D31), // latar gelap ala Discord
        borderRadius: BorderRadius.circular(14), // sudut membulat
        border: Border.all(color: equipped ? item.rarity.color : Colors.white10, width: equipped ? 2 : 1), // garis tepi menyala bila dipakai
      ),
      child: Column(children: [
        Expanded( // area gambar mengambil sisa tinggi
          child: Stack(children: [
            Positioned.fill(child: ItemPreviewArt(item: item)), // gambar item
            Positioned(top: 8, left: 8, child: RarityBadge(rarity: item.rarity)), // lencana rarity kiri atas
            if (owned) // tanda sudah dimiliki
              const Positioned(top: 8, right: 8, child: Icon(Icons.check_circle, color: Color(0xFF66BB6A), size: 20)), // centang hijau
            Positioned( // tombol pratinjau kanan bawah
              right: 6, bottom: 6,
              child: Material(
                color: Colors.black54, // latar tombol transparan
                shape: const StadiumBorder(), // bentuk pil
                child: InkWell(
                  customBorder: const StadiumBorder(), // area sentuh mengikuti bentuk
                  onTap: () => showPreviewSheet(context, item), // buka pratinjau langsung
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 9, vertical: 5), // jarak dalam
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.visibility, size: 13, color: Colors.white), // ikon mata
                      SizedBox(width: 4), // jarak
                      Text('Pratinjau', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)), // teks tombol
                    ]),
                  ),
                ),
              ),
            ),
          ]),
        ),
        Padding( // bagian nama dan aksi
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 10), // jarak dalam
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)), // nama item
            const SizedBox(height: 8), // jarak
            ShopActionButton(item: item, hostContext: context), // tombol aksi
          ]),
        ),
      ]),
    );
  }
}
