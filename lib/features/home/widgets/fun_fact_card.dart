import 'package:flutter/material.dart'; // widget dasar Flutter

import '../../../core/theme/app_theme.dart'; // warna aplikasi
import '../../../core/widgets/batik_pattern.dart'; // motif batik
import '../data/fun_facts.dart'; // data fakta

/// Kartu Fun Fact dinamis: fakta berganti tiap hari, bisa ditukar dengan tombol, khusus saat Hari Jadi Tuban.
class FunFactCard extends StatefulWidget {
  const FunFactCard({super.key}); // konstruktor
  @override
  State<FunFactCard> createState() => _FunFactCardState(); // buat state
}

class _FunFactCardState extends State<FunFactCard> {
  int _shift = 0; // pergeseran urutan fakta bila pengguna menekan "Fakta lain"

  @override
  Widget build(BuildContext context) { // membangun kartu
    final now = DateTime.now(); // tanggal hari ini
    final fact = factForDate(now, shift: _shift); // fakta terpilih
    final special = now.month == 11 && now.day == 12 && _shift == 0; // hari jadi?
    return Container(
      clipBehavior: Clip.antiAlias, // potong isi mengikuti sudut
      decoration: BoxDecoration( // hiasan kartu
        borderRadius: BorderRadius.circular(20), // sudut membulat
        gradient: LinearGradient(colors: special ? [AppColors.red, const Color(0xFF7E2418)] : [AppColors.indigo, const Color(0xFF1B2A55)]), // merah di hari jadi, indigo biasanya
      ),
      child: Stack(children: [
        const Positioned.fill(child: BatikOverlay(color: Color(0x14FFFFFF), cell: 36)), // aksen batik tipis
        Padding(
          padding: const EdgeInsets.all(16), // jarak dalam
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Icon(special ? Icons.celebration : Icons.lightbulb, color: AppColors.gold, size: 20), // ikon
              const SizedBox(width: 8), // jarak
              Text(special ? 'HARI INI' : 'TAHUKAH KAMU?', style: const TextStyle(color: AppColors.gold, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.2)), // label kecil
              const Spacer(), // dorong ke kanan
              InkWell(onTap: () => setState(() => _shift++), borderRadius: BorderRadius.circular(20), child: const Padding(padding: EdgeInsets.all(4), child: Row(children: [Text('Fakta lain', style: TextStyle(color: Colors.white70, fontSize: 12)), SizedBox(width: 2), Icon(Icons.refresh, color: Colors.white70, size: 16)]))), // tombol fakta lain
            ]),
            const SizedBox(height: 10), // jarak
            AnimatedSwitcher( // teks berganti halus
              duration: const Duration(milliseconds: 350), // lama transisi
              child: Column(key: ValueKey('${fact.title}$_shift'), crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(fact.title, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800)), // judul fakta
                const SizedBox(height: 6), // jarak
                Text(fact.text, style: const TextStyle(color: Colors.white70, height: 1.45)), // isi fakta
              ]),
            ),
          ]),
        ),
      ]),
    );
  }
}
