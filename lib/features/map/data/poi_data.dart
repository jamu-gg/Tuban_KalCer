import 'package:flutter/material.dart'; // IconData

import '../../../core/widgets/tuban_scene.dart'; // jenis ilustrasi

/// Satu foto ilustrasi di galeri Story Card.
class GalleryShot {
  final SceneKind kind; // pemandangan
  final int phase; // waktu: 0 pagi, 1 siang, 2 senja, 3 malam
  final bool flip; // cerminkan gambar
  final String caption; // keterangan foto
  const GalleryShot(this.kind, this.phase, this.caption, {this.flip = false}); // konstruktor
}

/// Satu titik lokasi penting (Point of Interest) di peta Tuban.
class Poi {
  final String id; // kode unik lokasi
  final String name; // nama lokasi
  final String subtitle; // keterangan singkat
  final List<String> paragraphs; // narasi per paragraf (dipakai untuk narasi dan progres baca)
  final List<GalleryShot> gallery; // galeri ilustrasi
  final double x; // posisi mendatar di peta (0 kiri sampai 1 kanan)
  final double y; // posisi tegak di peta (0 atas sampai 1 bawah)
  final IconData icon; // ikon lokasi
  final int reward; // koin yang didapat setelah menyelesaikan misi baca

  const Poi({ // konstruktor konstan
    required this.id, required this.name, required this.subtitle, // identitas
    required this.paragraphs, required this.gallery, // isi
    required this.x, required this.y, required this.icon, // posisi dan ikon
    this.reward = 10, // hadiah bawaan 10 koin
  });

  String get story => paragraphs.join('\n\n'); // narasi utuh
}

/// Daftar lokasi. Narasi bersifat ringkas dan perlu dicocokkan dengan sumber resmi sebelum dipublikasikan.
const List<Poi> poiList = [
  Poi( // Pantai Boom
    id: 'pantai_boom', name: 'Pantai Boom', subtitle: 'Bekas pelabuhan lama di tepi laut Tuban', // identitas
    paragraphs: [
      'Pantai Boom berada di tepi laut kota Tuban dan dikenal sebagai kawasan pelabuhan lama.', // paragraf 1
      'Sejak berabad-abad lalu Tuban menjadi kota dagang di pesisir utara Jawa, tempat kapal singgah membawa barang dan kabar dari berbagai negeri.', // paragraf 2
      'Kini kawasan ini menjadi tempat warga menikmati laut dan senja.', // paragraf 3
    ],
    gallery: [GalleryShot(SceneKind.pantai, 0, 'Pagi di Pantai Boom'), GalleryShot(SceneKind.pantai, 1, 'Siang yang cerah', flip: true), GalleryShot(SceneKind.pantai, 2, 'Senja di tepi laut')], // galeri
    x: 0.42, y: 0.24, icon: Icons.beach_access, // posisi dan ikon
  ),
  Poi( // Klenteng Kwan Sing Bio
    id: 'klenteng_kwan_sing_bio', name: 'Klenteng Kwan Sing Bio', subtitle: 'Tempat ibadah umat Tridharma', // identitas
    paragraphs: [
      'Klenteng Kwan Sing Bio adalah tempat ibadah umat Tridharma di kota Tuban.', // paragraf 1
      'Bangunannya berhias warna merah dan ornamen khas Tionghoa.', // paragraf 2
      'Klenteng ini mengingatkan bahwa pesisir Tuban sejak lama dihuni masyarakat dari beragam latar budaya yang hidup berdampingan.', // paragraf 3
    ],
    gallery: [GalleryShot(SceneKind.klenteng, 1, 'Atap berujung melengkung'), GalleryShot(SceneKind.klenteng, 2, 'Lampion di waktu senja', flip: true), GalleryShot(SceneKind.klenteng, 3, 'Malam di halaman klenteng')], // galeri
    x: 0.64, y: 0.34, icon: Icons.temple_buddhist, // posisi dan ikon
  ),
  Poi( // Gua Akbar
    id: 'gua_akbar', name: 'Gua Akbar', subtitle: 'Gua berstalaktit di tengah kota', // identitas
    paragraphs: [
      'Gua Akbar terletak di tengah kota Tuban.', // paragraf 1
      'Di dalamnya ada lorong dan ruang berhias stalaktit serta stalagmit yang terbentuk dari tetesan air selama waktu yang sangat panjang.', // paragraf 2
      'Gua ini menjadi tujuan wisata sejarah dan alam yang mudah dijangkau warga.', // paragraf 3
    ],
    gallery: [GalleryShot(SceneKind.gua, 1, 'Stalaktit di langit-langit gua'), GalleryShot(SceneKind.gua, 1, 'Lorong yang temaram', flip: true)], // galeri
    x: 0.28, y: 0.46, icon: Icons.landscape, // posisi dan ikon
  ),
  Poi( // Makam Sunan Bonang
    id: 'makam_sunan_bonang', name: 'Makam Sunan Bonang', subtitle: 'Jejak Bumi Wali', // identitas
    paragraphs: [
      'Sunan Bonang adalah salah satu tokoh penyebar Islam di tanah Jawa yang dimakamkan di Tuban.', // paragraf 1
      'Kompleks makamnya ramai dikunjungi peziarah.', // paragraf 2
      'Karena itulah Tuban dijuluki Bumi Wali.', // paragraf 3
    ],
    gallery: [GalleryShot(SceneKind.makam, 0, 'Pagi di kompleks makam'), GalleryShot(SceneKind.makam, 1, 'Kubah hijau di bawah langit siang', flip: true), GalleryShot(SceneKind.makam, 3, 'Malam yang tenang')], // galeri
    x: 0.72, y: 0.55, icon: Icons.mosque, // posisi dan ikon
  ),
  Poi( // Tenun Gedog Kerek
    id: 'tenun_gedog_kerek', name: 'Tenun Gedog Kerek', subtitle: 'Sentra kain tenun khas Tuban', // identitas
    paragraphs: [
      'Gedog adalah kain tenun tradisional Tuban yang dibuat dengan alat tenun gedog.', // paragraf 1
      'Bunyi alat tenunnya menjadi asal nama kainnya.', // paragraf 2
      'Benang dipintal dari kapas lalu dibatik dan diwarnai.', // paragraf 3
      'Salah satu sentra pengrajinnya ada di Kecamatan Kerek.', // paragraf 4
    ],
    gallery: [GalleryShot(SceneKind.tenun, 1, 'Alat tenun dan kain bermotif kawung'), GalleryShot(SceneKind.tenun, 1, 'Teropong tenun bergerak', flip: true)], // galeri
    x: 0.40, y: 0.80, icon: Icons.checkroom, // posisi dan ikon
  ),
];
