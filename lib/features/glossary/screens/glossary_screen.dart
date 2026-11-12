import 'package:flutter/material.dart'; // widget dasar Flutter

import '../../../core/database/database_helper.dart'; // simpan favorit dan jejak baca
import '../../../core/theme/app_theme.dart'; // warna aplikasi
import '../../../core/widgets/batik_pattern.dart'; // aksen batik
import '../../achievements/widgets/achievement_widgets.dart'; // toast lencana
import '../data/glossary_data.dart'; // data istilah
import '../models/glossary_term.dart'; // model istilah
import '../widgets/term_tile.dart'; // kartu istilah

/// Kamus Tuban: cari, saring per kelompok, tandai favorit, dan baca penjelasan istilah budaya.
class GlossaryScreen extends StatefulWidget {
  const GlossaryScreen({super.key}); // konstruktor
  @override
  State<GlossaryScreen> createState() => _GlossaryScreenState(); // buat state
}

class _GlossaryScreenState extends State<GlossaryScreen> {
  final TextEditingController _search = TextEditingController(); // isian pencarian
  GlossCategory? _filter; // kelompok terpilih (null = semua)
  bool _onlyFav = false; // tampilkan hanya favorit?
  String? _open; // id istilah yang sedang terbuka
  Set<String> _fav = {}; // id favorit
  Set<String> _seen = {}; // id yang sudah dibaca

  @override
  void initState() { // dipanggil sekali
    super.initState(); // panggil induk
    _load(); // muat favorit dan jejak baca
  }

  @override
  void dispose() { // dipanggil saat layar ditutup
    _search.dispose(); // bebaskan pengendali
    super.dispose(); // panggil induk
  }

  /// Membaca favorit dan istilah yang sudah dibaca dari SQLite.
  Future<void> _load() async { // muat data
    final db = DatabaseHelper.instance; // pembantu database
    final fav = await db.getGameStatesByPrefix('gloss_fav_'); // kunci favorit
    final seen = await db.getGameStatesByPrefix('gloss_seen_'); // kunci dibaca
    if (!mounted) return; // pastikan layar masih ada
    setState(() { // perbarui tampilan
      _fav = fav.keys.map((k) => k.substring('gloss_fav_'.length)).toSet(); // buang awalan
      _seen = seen.keys.map((k) => k.substring('gloss_seen_'.length)).toSet(); // buang awalan
    });
  }

  /// Membuka/menutup istilah; saat dibuka pertama kali dicatat sebagai sudah dibaca.
  Future<void> _toggle(GlossaryTerm t) async { // buka tutup
    final opening = _open != t.id; // akan dibuka?
    setState(() => _open = opening ? t.id : null); // ubah istilah terbuka
    if (opening && !_seen.contains(t.id)) { // pertama kali dibaca
      await DatabaseHelper.instance.setGameState('gloss_seen_${t.id}', '1'); // simpan ke database
      if (!mounted) return; // pastikan layar masih ada
      setState(() => _seen = {..._seen, t.id}); // perbarui himpunan lokal
      if (_seen.length >= 10) await unlockWithToast(context, 'kolektor_kata'); // lencana kolektor kata
    }
  }

  /// Menandai atau melepas favorit.
  Future<void> _toggleFav(GlossaryTerm t) async { // ubah favorit
    final key = 'gloss_fav_${t.id}'; // kunci database
    if (_fav.contains(t.id)) { await DatabaseHelper.instance.deleteGameState(key); setState(() => _fav = {..._fav}..remove(t.id)); } // lepas favorit
    else { await DatabaseHelper.instance.setGameState(key, '1'); setState(() => _fav = {..._fav, t.id}); } // jadikan favorit
  }

  @override
  Widget build(BuildContext context) { // membangun layar
    final q = _search.text.trim().toLowerCase(); // kata pencarian
    final list = glossaryTerms.where((t) { // saring daftar
      if (_filter != null && t.category != _filter) return false; // sesuai kelompok
      if (_onlyFav && !_fav.contains(t.id)) return false; // hanya favorit
      if (q.isEmpty) return true; // tanpa pencarian
      return t.term.toLowerCase().contains(q) || t.meaning.toLowerCase().contains(q); // cocok istilah atau arti
    }).toList()..sort((a, b) => a.term.toLowerCase().compareTo(b.term.toLowerCase())); // urut abjad
    return Scaffold(
      appBar: AppBar(title: const Text('Kamus Tuban')), // bilah atas
      body: Column(children: [
        Container( // kepala bermotif batik berisi pencarian
          padding: const EdgeInsets.fromLTRB(14, 4, 14, 14), // jarak dalam
          decoration: const BoxDecoration(color: AppColors.green, borderRadius: BorderRadius.vertical(bottom: Radius.circular(22))), // hijau dengan sudut bawah membulat
          clipBehavior: Clip.antiAlias, // potong motif
          child: Stack(children: [
            const Positioned.fill(child: BatikOverlay(color: Color(0x1AFFFFFF), cell: 36)), // aksen batik
            Column(children: [
              TextField(
                controller: _search, // isian
                onChanged: (_) => setState(() {}), // saring saat mengetik
                decoration: InputDecoration(
                  hintText: 'Cari istilah, contoh: legen', // petunjuk
                  prefixIcon: const Icon(Icons.search), // ikon cari
                  suffixIcon: q.isEmpty ? null : IconButton(onPressed: () => setState(_search.clear), icon: const Icon(Icons.clear)), // tombol hapus
                  filled: true, fillColor: Colors.white, // latar putih
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none), // tanpa garis tepi
                  contentPadding: const EdgeInsets.symmetric(vertical: 0), // rapatkan
                ),
              ),
              const SizedBox(height: 10), // jarak
              SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [ // baris chip kelompok
                _chip('Semua', _filter == null && !_onlyFav, () => setState(() { _filter = null; _onlyFav = false; })), // semua
                _chip('Favorit', _onlyFav, () => setState(() { _onlyFav = !_onlyFav; _filter = null; }), icon: Icons.star), // favorit
                for (final c in GlossCategory.values) _chip(c.label, _filter == c, () => setState(() { _filter = _filter == c ? null : c; _onlyFav = false; }), icon: c.icon), // tiap kelompok
              ])),
            ]),
          ]),
        ),
        Padding(padding: const EdgeInsets.fromLTRB(16, 10, 16, 0), child: Row(children: [
          Text('${list.length} istilah', style: const TextStyle(color: Colors.black54)), // jumlah hasil
          const Spacer(), // dorong ke kanan
          Text('Dibaca ${_seen.length}/${glossaryTerms.length}', style: const TextStyle(color: AppColors.green, fontWeight: FontWeight.w700)), // kemajuan baca
        ])),
        Expanded(child: list.isEmpty
            ? const Center(child: Text('Istilah tidak ditemukan.', style: TextStyle(color: Colors.black54))) // hasil kosong
            : ListView.builder(
                padding: const EdgeInsets.all(16), // jarak tepi
                itemCount: list.length, // jumlah kartu
                itemBuilder: (_, i) { // bangun kartu
                  final t = list[i]; // istilah
                  return TermTile(term: t, favorite: _fav.contains(t.id), seen: _seen.contains(t.id), expanded: _open == t.id, onTap: () => _toggle(t), onFavorite: () => _toggleFav(t)); // kartu istilah
                },
              )),
      ]),
    );
  }

  /// Chip penyaring.
  Widget _chip(String label, bool selected, VoidCallback onTap, {IconData? icon}) => Padding( // satu chip
    padding: const EdgeInsets.only(right: 8), // jarak antar chip
    child: ChoiceChip(
      label: Text(label), // teks
      avatar: icon == null ? null : Icon(icon, size: 16, color: selected ? Colors.white : AppColors.green), // ikon
      selected: selected, // terpilih?
      onSelected: (_) => onTap(), // aksi
      selectedColor: AppColors.indigo, // warna terpilih
      labelStyle: TextStyle(color: selected ? Colors.white : AppColors.greenDark, fontWeight: FontWeight.w700), // gaya teks
      showCheckmark: false, // tanpa centang
    ),
  );
}
