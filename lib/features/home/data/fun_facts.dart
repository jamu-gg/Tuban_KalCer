/// Satu fakta menarik tentang Tuban.
class FunFact {
  final String title; // judul singkat
  final String text; // isi fakta
  const FunFact(this.title, this.text); // konstruktor konstan
}

/// Daftar fakta. Isi ringkas; cocokkan dengan sumber resmi sebelum dipublikasikan.
const List<FunFact> funFacts = [
  FunFact('Asal nama gedog', 'Kain gedog dinamai dari bunyi alat tenunnya yang berbunyi "dog-dog" saat dipakai menenun.'), // fakta 1
  FunFact('Legen segar', 'Legen adalah nira pohon siwalan. Rasanya manis dan paling nikmat diminum dingin saat masih segar.'), // fakta 2
  FunFact('Bumi Wali', 'Tuban dijuluki Bumi Wali karena Sunan Bonang, salah satu penyebar Islam di Jawa, dimakamkan di sini.'), // fakta 3
  FunFact('Kota bandar', 'Letaknya di pesisir utara Jawa menjadikan Tuban pelabuhan dagang penting sejak masa Majapahit.'), // fakta 4
  FunFact('Siwalan serbaguna', 'Pohon siwalan memberi buah, nira, gula, hingga daun untuk anyaman. Hampir semua bagiannya terpakai.'), // fakta 5
  FunFact('Gua di tengah kota', 'Gua Akbar berada di tengah kota Tuban dan memiliki lorong berhias stalaktit dan stalagmit.'), // fakta 6
  FunFact('Benang dari kapas', 'Benang kain gedog dipintal dari kapas, lalu ditenun dan dibatik dengan pewarna.'), // fakta 7
  FunFact('Beragam budaya', 'Klenteng Kwan Sing Bio dan Makam Sunan Bonang berdiri di kota yang sama: bukti keberagaman yang hidup berdampingan.'), // fakta 8
  FunFact('Dua nama stalaktit', 'Batu runcing yang menggantung di gua disebut stalaktit; yang tumbuh dari lantai disebut stalagmit.'), // fakta 9
];

/// Fakta khusus Hari Jadi Tuban (12 November); jumlah tahun dihitung dari 1293.
FunFact hariJadiFact(int year) => FunFact('Hari Jadi Tuban', 'Hari ini Tuban memperingati hari jadinya yang ke-${year - 1293}. Tahun dasarnya 1293 dan diperingati tiap 12 November.'); // fakta khusus

/// Memilih fakta untuk tanggal tertentu: hari jadi bila 12 November, selain itu berputar menurut urutan hari dalam tahun.
FunFact factForDate(DateTime d, {int shift = 0}) { // pemilih fakta
  if (d.month == 11 && d.day == 12 && shift == 0) return hariJadiFact(d.year); // khusus hari jadi
  final dayOfYear = d.difference(DateTime(d.year, 1, 1)).inDays; // urutan hari dalam tahun
  return funFacts[(dayOfYear + shift) % funFacts.length]; // pilih berputar
}
