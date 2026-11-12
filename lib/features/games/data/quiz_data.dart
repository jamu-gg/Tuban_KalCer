/// Satu soal kuis pilihan ganda beserta penjelasan yang muncul setelah menjawab.
class QuizQuestion {
  final String category; // kelompok soal (Sejarah, Kuliner, dll.)
  final String question; // teks pertanyaan
  final List<String> options; // pilihan jawaban
  final int answerIndex; // nomor pilihan yang benar (mulai dari 0)
  final String explanation; // penjelasan singkat "Tahukah kamu"
  const QuizQuestion(this.category, this.question, this.options, this.answerIndex, this.explanation); // konstruktor konstan
}

/// Bank soal kuis budaya Tuban (diacak dan diambil 5 tiap permainan).
/// Catatan: isi penjelasan ringkas dan perlu dicocokkan dengan sumber resmi sebelum dipublikasikan.
const List<QuizQuestion> quizBank = [
  QuizQuestion('Sejarah', 'Apa julukan Kabupaten Tuban yang berkaitan dengan para penyebar Islam?', ['Bumi Wali', 'Kota Gudeg', 'Kota Apel', 'Kota Kretek'], 0, 'Tuban dijuluki Bumi Wali karena salah satu wali, Sunan Bonang, dimakamkan di sini.'), // soal 1
  QuizQuestion('Kuliner', 'Minuman manis segar dari nira pohon siwalan disebut...', ['Legen', 'Wedang Jahe', 'Es Dawet', 'Bajigur'], 0, 'Legen adalah nira siwalan segar yang rasanya manis dan biasanya diminum dingin.'), // soal 2
  QuizQuestion('Tenun', 'Kain tenun tradisional khas Tuban bernama...', ['Gedog', 'Ulos', 'Songket', 'Lurik Jogja'], 0, 'Kain gedog ditenun dengan alat tenun gedog dan dikenal lewat benang kapas yang dipintal tangan.'), // soal 3
  QuizQuestion('Tempat', 'Gua wisata yang berada di tengah kota Tuban adalah...', ['Gua Akbar', 'Gua Jomblang', 'Gua Pindul', 'Gua Gong'], 0, 'Gua Akbar berada di tengah kota dan memiliki lorong berhias stalaktit.'), // soal 4
  QuizQuestion('Tempat', 'Kawasan pelabuhan lama di tepi laut kota Tuban dikenal dengan nama...', ['Pantai Boom', 'Pantai Kuta', 'Pantai Parangtritis', 'Pantai Pandawa'], 0, 'Pantai Boom adalah bekas kawasan pelabuhan lama yang kini menjadi tempat warga menikmati laut.'), // soal 5
  QuizQuestion('Sejarah', 'Tokoh wali yang dimakamkan di Tuban adalah...', ['Sunan Bonang', 'Sunan Kudus', 'Sunan Muria', 'Sunan Kalijaga'], 0, 'Makam Sunan Bonang di Tuban ramai dikunjungi peziarah dari berbagai daerah.'), // soal 6
  QuizQuestion('Tenun', 'Benang untuk kain gedog dipintal dari...', ['Kapas', 'Sutra ulat', 'Serat nanas', 'Wol domba'], 0, 'Kapas dipintal menjadi benang, lalu ditenun dan dibatik menjadi kain gedog.'), // soal 7
  QuizQuestion('Tempat', 'Klenteng terkenal di kota Tuban bernama...', ['Kwan Sing Bio', 'Sam Poo Kong', 'Boen Bio', 'Ban Hing Kiong'], 0, 'Kwan Sing Bio adalah klenteng di Tuban yang memuliakan Kwan Sing Tee Koen (Guan Yu).'), // soal 8
  QuizQuestion('Kuliner', 'Pohon siwalan juga dikenal dengan nama lain...', ['Lontar', 'Aren', 'Sagu', 'Nipah'], 0, 'Siwalan atau lontar (Borassus flabellifer) menghasilkan buah dan nira untuk legen.'), // soal 9
  QuizQuestion('Sejarah', 'Hari jadi Tuban diperingati setiap tanggal...', ['12 November', '17 Agustus', '2 Mei', '21 April'], 0, 'Hari Jadi Tuban diperingati setiap 12 November, dengan tahun dasar 1293.'), // soal 10
  QuizQuestion('Tempat', 'Tuban terletak di wilayah...', ['Pantai utara Jawa', 'Pantai selatan Jawa', 'Pegunungan Bromo', 'Pulau Madura'], 0, 'Tuban berada di pesisir utara Jawa (pantura), jalur dagang sejak masa lampau.'), // soal 11
  QuizQuestion('Tenun', 'Motif batik berpola bulatan atau elips teratur yang melambangkan kesucian disebut...', ['Kawung', 'Parang', 'Mega Mendung', 'Truntum'], 0, 'Kawung adalah motif geometris klasik berbentuk elips yang tersusun rapi.'), // soal 12
  QuizQuestion('Tenun', 'Nama kain gedog diyakini berasal dari...', ['Bunyi alat tenunnya', 'Nama desa pembuatnya', 'Warna kainnya', 'Nama seorang raja'], 0, 'Alat tenun gedog berbunyi "dog-dog" saat dipakai, dan bunyi itulah yang jadi nama kainnya.'), // soal 13
  QuizQuestion('Bahasa', '"Sugeng rawuh" dalam bahasa Jawa artinya...', ['Selamat datang', 'Terima kasih', 'Selamat tinggal', 'Permisi'], 0, 'Sugeng rawuh dipakai untuk menyambut tamu dengan hormat.'), // soal 14
  QuizQuestion('Bahasa', '"Matur nuwun" dalam bahasa Jawa artinya...', ['Terima kasih', 'Selamat pagi', 'Maaf', 'Sampai jumpa'], 0, 'Matur nuwun adalah ungkapan terima kasih yang sopan dalam bahasa Jawa.'), // soal 15
  QuizQuestion('Kuliner', 'Nira siwalan yang dibiarkan lama dan terfermentasi disebut...', ['Tuak', 'Legen segar', 'Wedang uwuh', 'Sirup'], 0, 'Fermentasi membuat nira menjadi tuak; legen yang segar belum terfermentasi.'), // soal 16
  QuizQuestion('Sejarah', 'Pada masa Majapahit, Tuban dikenal sebagai...', ['Bandar pelabuhan penting', 'Pusat pertambangan emas', 'Kota benteng pegunungan', 'Ibu kota kerajaan'], 0, 'Letaknya di pesisir membuat Tuban menjadi pelabuhan dagang penting di utara Jawa.'), // soal 17
  QuizQuestion('Tempat', 'Hiasan batu runcing yang menggantung dari langit-langit gua disebut...', ['Stalaktit', 'Stalagmit', 'Kristal', 'Fosil'], 0, 'Stalaktit tumbuh dari atas ke bawah oleh tetesan air; stalagmit tumbuh dari lantai ke atas.'), // soal 18
];
