import 'package:flutter/material.dart'; // widget dasar Flutter
import 'package:provider/provider.dart'; // membaca provider

import '../../../core/theme/app_theme.dart'; // warna aplikasi
import '../../achievements/models/achievement.dart'; // kelompok lencana
import '../../achievements/providers/achievement_provider.dart'; // lencana
import '../../achievements/widgets/achievement_widgets.dart'; // toast dan kisi lencana
import '../../coin/providers/coin_provider.dart'; // hadiah koin
import '../../coin/widgets/reward_dialog.dart'; // pop-up hadiah
import '../data/poi_data.dart'; // daftar lokasi
import '../widgets/map_canvas.dart'; // latar peta vektor
import '../widgets/story_card.dart'; // kartu cerita

/// Peta interaktif: geser dan cubit untuk zoom, ketuk pin berdenyut untuk membuka Story Card.
class MapScreen extends StatefulWidget {
  const MapScreen({super.key}); // konstruktor konstan

  @override
  State<MapScreen> createState() => _MapScreenState(); // buat state layar
}

class _MapScreenState extends State<MapScreen> with SingleTickerProviderStateMixin {
  final Set<String> _claimed = {}; // id lokasi yang misinya sudah selesai
  late final AnimationController _anim = AnimationController(vsync: this, duration: const Duration(seconds: 6))..repeat(); // animasi ombak dan denyut pin

  @override
  void initState() { // dipanggil sekali
    super.initState(); // panggil induk
    _loadClaimed(); // muat status klaim
  }

  @override
  void dispose() { // dipanggil saat layar ditutup
    _anim.dispose(); // hentikan animasi
    super.dispose(); // panggil induk
  }

  /// Membaca status klaim tiap lokasi dari SQLite.
  Future<void> _loadClaimed() async { // muat status
    final coin = context.read<CoinProvider>(); // penyedia koin
    for (final p in poiList) { if (await coin.isStoryClaimed(p.id)) _claimed.add(p.id); } // catat yang sudah diklaim
    if (mounted) setState(() {}); // gambar ulang
  }

  /// Membuka Story Card; bila misi selesai, beri hadiah dan periksa lencana jelajah.
  Future<void> _openStory(Poi poi) async { // buka kartu cerita
    final finished = await showModalBottomSheet<bool>(
      context: context, // konteks layar
      isScrollControlled: true, // boleh tinggi
      useSafeArea: true, // hindari poni
      backgroundColor: Colors.transparent, // kartu menggambar latarnya sendiri
      builder: (_) => StoryCard(poi: poi, alreadyClaimed: _claimed.contains(poi.id)), // isi kartu
    );
    if (finished != true || !mounted) return; // lanjut hanya jika misi selesai
    final coin = context.read<CoinProvider>(); // penyedia koin
    final ach = context.read<AchievementProvider>(); // penyedia lencana
    final given = await coin.claimStoryReward(poi.id, poi.reward); // coba klaim hadiah
    if (!mounted) return; // pastikan layar masih ada
    if (!given) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Hadiah lokasi ini sudah pernah diambil.'))); return; } // sudah pernah
    setState(() => _claimed.add(poi.id)); // tandai lokasi selesai
    await showRewardDialog(context, coins: poi.reward, message: 'Kamu menyelesaikan misi di ${poi.name}.'); // pop-up hadiah
    final fresh = await ach.evaluateExploration(_claimed); // periksa lencana jelajah
    if (!mounted) return; // pastikan layar masih ada
    for (final a in fresh) { showAchievementToast(context, a); } // tampilkan tiap lencana baru
  }

  /// Lembar daftar lencana jelajah.
  void _showBadges() { // tampilkan lencana
    showModalBottomSheet<void>(
      context: context, // konteks layar
      backgroundColor: AppColors.cream, // latar krem
      isScrollControlled: true, // tinggi menyesuaikan isi
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))), // sudut atas membulat
      builder: (_) => Padding(padding: const EdgeInsets.fromLTRB(16, 18, 16, 28), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Lencana Penjelajah', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.greenDark)), // judul
        const SizedBox(height: 12), // jarak
        const AchievementGrid(only: AchievementGroup.jelajah), // kisi lencana jelajah
      ])),
    );
  }

  @override
  Widget build(BuildContext context) { // membangun layar peta
    final unlocked = context.watch<AchievementProvider>().unlocked; // pantau lencana
    final jelajahTotal = achievementList.where((a) => a.group == AchievementGroup.jelajah).length; // jumlah lencana jelajah
    final jelajahOpen = achievementList.where((a) => a.group == AchievementGroup.jelajah && unlocked.contains(a.id)).length; // yang terbuka
    return Scaffold(
      appBar: AppBar(title: const Text('Jelajah Tuban'), actions: [
        IconButton(onPressed: _showBadges, tooltip: 'Lencana', icon: Badge(label: Text('$jelajahOpen'), child: const Icon(Icons.emoji_events))), // tombol lencana dengan jumlah
      ]),
      body: LayoutBuilder(builder: (context, box) { // ukur ruang yang tersedia
        final w = box.maxWidth, h = box.maxHeight; // ukuran peta
        return Stack(children: [
          InteractiveViewer( // geser dan cubit untuk zoom
            minScale: 1, maxScale: 2.8, // batas zoom
            child: SizedBox(width: w, height: h, child: Stack(children: [
              Positioned.fill(child: MapCanvas(anim: _anim)), // latar vektor
              for (final p in poiList) // satu pin per lokasi
                Positioned(
                  left: p.x * w - 48, top: p.y * h - 58, // ujung pin tepat di titik lokasi
                  child: _Pin(poi: p, done: _claimed.contains(p.id), anim: _anim, onTap: () => _openStory(p)), // pin berdenyut
                ),
            ])),
          ),
          Positioned(top: 10, left: 12, right: 12, child: _ProgressCard(done: _claimed.length, total: poiList.length, badges: jelajahOpen, badgeTotal: jelajahTotal)), // kartu kemajuan
        ]);
      }),
    );
  }
}

/// Kartu kemajuan jelajah di atas peta.
class _ProgressCard extends StatelessWidget {
  final int done, total, badges, badgeTotal; // angka kemajuan
  const _ProgressCard({required this.done, required this.total, required this.badges, required this.badgeTotal}); // konstruktor
  @override
  Widget build(BuildContext context) { // membangun kartu
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10), // jarak dalam
      decoration: BoxDecoration(color: Colors.white.withAlpha(235), borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(blurRadius: 8, color: Colors.black12)]), // kartu putih
      child: Row(children: [
        const Icon(Icons.explore, color: AppColors.green), // ikon jelajah
        const SizedBox(width: 10), // jarak
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('$done dari $total lokasi selesai  ·  $badges/$badgeTotal lencana', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5)), // keterangan
          const SizedBox(height: 5), // jarak
          ClipRRect(borderRadius: BorderRadius.circular(5), child: LinearProgressIndicator(value: total == 0 ? 0 : done / total, minHeight: 7, color: AppColors.green, backgroundColor: Colors.black12)), // bilah kemajuan
        ])),
      ]),
    );
  }
}

/// Pin lokasi: berdenyut bila belum selesai, hijau berpenanda centang bila selesai.
class _Pin extends StatelessWidget {
  final Poi poi; // lokasi
  final bool done; // sudah selesai?
  final Animation<double> anim; // animasi denyut
  final VoidCallback onTap; // aksi ketuk
  const _Pin({required this.poi, required this.done, required this.anim, required this.onTap}); // konstruktor

  @override
  Widget build(BuildContext context) { // membangun pin
    final color = done ? AppColors.green : AppColors.red; // warna pin
    return GestureDetector(
      onTap: onTap, // buka Story Card
      behavior: HitTestBehavior.opaque, // seluruh kotak peka sentuh
      child: SizedBox(width: 96, child: Column(children: [
        SizedBox(height: 58, width: 96, child: AnimatedBuilder(
          animation: anim, // ikuti animasi
          builder: (_, __) {
            final pulse = (anim.value * 3) % 1.0; // denyut 3 kali per putaran
            return Stack(alignment: Alignment.bottomCenter, children: [
              if (!done) Positioned(bottom: -4, child: Opacity(opacity: (1 - pulse) * 0.55, child: Container(width: 20 + 50 * pulse, height: 8 + 18 * pulse, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.gold, width: 2.2))))), // riak emas di tanah
              Stack(alignment: Alignment.topCenter, children: [
                Icon(Icons.location_on, size: 56, color: color, shadows: const [Shadow(blurRadius: 6, color: Colors.black45)]), // badan pin
                Positioned(top: 11, child: Icon(done ? Icons.check : poi.icon, size: 20, color: Colors.white)), // ikon di lubang pin
              ]),
            ]);
          },
        )),
        Container( // label nama di bawah ujung pin
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2), // jarak dalam
          decoration: BoxDecoration(color: Colors.white.withAlpha(230), borderRadius: BorderRadius.circular(8)), // kotak putih membulat
          child: Text(poi.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700)), // nama
        ),
      ])),
    );
  }
}
