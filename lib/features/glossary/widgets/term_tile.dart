import 'package:flutter/material.dart'; // widget dasar Flutter

import '../../../core/theme/app_theme.dart'; // warna aplikasi
import '../models/glossary_term.dart'; // model istilah

/// Satu kartu istilah yang dapat dibuka untuk membaca penjelasan lengkap.
class TermTile extends StatelessWidget {
  final GlossaryTerm term; // istilah
  final bool favorite; // ditandai favorit?
  final bool seen; // sudah pernah dibaca?
  final bool expanded; // sedang terbuka?
  final VoidCallback onTap; // ketuk untuk buka/tutup
  final VoidCallback onFavorite; // ketuk bintang
  const TermTile({super.key, required this.term, required this.favorite, required this.seen, required this.expanded, required this.onTap, required this.onFavorite}); // konstruktor

  @override
  Widget build(BuildContext context) { // membangun kartu
    final c = term.category.color; // warna kelompok
    return Container(
      margin: const EdgeInsets.only(bottom: 10), // jarak antar kartu
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border(left: BorderSide(color: c, width: 5))), // kartu putih dengan garis warna di kiri
      child: Material(
        color: Colors.transparent, // permukaan transparan
        child: InkWell(
          borderRadius: BorderRadius.circular(16), // efek ketuk mengikuti sudut
          onTap: onTap, // buka/tutup
          child: Padding(
            padding: const EdgeInsets.all(14), // jarak dalam
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Icon(term.category.icon, size: 18, color: c), // ikon kelompok
                const SizedBox(width: 8), // jarak
                Expanded(child: Text(term.term, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.greenDark))), // istilah
                if (seen) const Icon(Icons.check_circle, size: 16, color: AppColors.green), // tanda sudah dibaca
                IconButton(visualDensity: VisualDensity.compact, onPressed: onFavorite, icon: Icon(favorite ? Icons.star : Icons.star_border, color: favorite ? AppColors.gold : Colors.black38)), // tombol favorit
              ]),
              Text(term.meaning, style: const TextStyle(fontSize: 14, height: 1.4)), // arti singkat
              AnimatedSize( // penjelasan terbuka mulus
                duration: const Duration(milliseconds: 250), // lama animasi
                alignment: Alignment.topCenter, // tumbuh dari atas
                child: expanded
                    ? Padding(padding: const EdgeInsets.only(top: 10), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(term.detail, style: const TextStyle(color: Colors.black87, height: 1.5)), // penjelasan lengkap
                        if (term.example != null) Container(
                          margin: const EdgeInsets.only(top: 10), padding: const EdgeInsets.all(10), // jarak luar dan dalam
                          decoration: BoxDecoration(color: AppColors.cream, borderRadius: BorderRadius.circular(10)), // kotak krem
                          child: Row(children: [const Icon(Icons.format_quote, size: 18, color: AppColors.indigo), const SizedBox(width: 6), Expanded(child: Text(term.example!, style: const TextStyle(fontStyle: FontStyle.italic)))]), // contoh kalimat
                        ),
                      ]))
                    : const SizedBox(width: double.infinity), // kosong saat tertutup
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
