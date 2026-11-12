import 'dart:math' as math; // sin untuk getar jawaban salah
import 'package:flutter/material.dart'; // widget dasar Flutter
import 'package:flutter/services.dart'; // HapticFeedback dan suara
import 'package:provider/provider.dart'; // membaca provider

import '../../../core/database/database_helper.dart'; // simpan rekor
import '../../../core/theme/app_theme.dart'; // warna aplikasi
import '../../achievements/widgets/achievement_widgets.dart'; // toast lencana
import '../../coin/providers/coin_provider.dart'; // koin dan bonus combo
import '../../coin/widgets/reward_dialog.dart'; // pop-up hadiah
import '../data/quiz_data.dart'; // bank soal
import '../widgets/carved_frame.dart'; // bingkai ukiran dan teks melayang

/// Kuis trivia: 5 soal, 15 detik per soal, koin per jawaban benar + bonus combo.
class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key}); // konstruktor konstan

  @override
  State<QuizScreen> createState() => _QuizScreenState(); // buat state
}

class _QuizScreenState extends State<QuizScreen> with SingleTickerProviderStateMixin {
  static const int _perQuestion = 15; // detik per soal
  late final List<QuizQuestion> _questions; // 5 soal terpilih
  final List<List<int>> _order = []; // urutan pilihan acak per soal
  late final AnimationController _timer; // pengatur waktu yang mulus (untuk cincin waktu)
  int _index = 0; // nomor soal berjalan
  int? _selected; // posisi pilihan pemain (-1 = waktu habis; null = belum menjawab)
  int _streak = 0; // jawaban benar beruntun
  int _bestStreak = 0; // combo terbaik
  int _correct = 0; // jumlah benar
  int _earned = 0; // koin terkumpul
  int _gainToken = 0; // pemicu efek "+N" melayang
  String _gainText = ''; // isi efek "+N"
  bool _closing = false; // sudah menutup layar?

  @override
  void initState() { // dipanggil sekali
    super.initState(); // panggil induk
    _questions = (List<QuizQuestion>.of(quizBank)..shuffle()).take(5).toList(); // acak lalu ambil 5 soal
    for (final q in _questions) { _order.add(List<int>.generate(q.options.length, (i) => i)..shuffle()); } // acak urutan pilihan tiap soal
    _timer = AnimationController(vsync: this, duration: const Duration(seconds: _perQuestion)) // timer 15 detik
      ..addStatusListener((s) { if (s == AnimationStatus.completed) _answer(-1); }) // habis waktu dianggap salah
      ..forward(); // mulai menghitung
  }

  @override
  void dispose() { // dipanggil saat layar ditutup
    _timer.dispose(); // hentikan timer
    super.dispose(); // panggil induk
  }

  void _answer(int pos) { // proses jawaban; -1 = waktu habis
    if (_selected != null || _closing) return; // abaikan bila sudah menjawab
    _timer.stop(); // hentikan timer
    final q = _questions[_index]; // soal berjalan
    final original = pos == -1 ? -1 : _order[_index][pos]; // ubah posisi tampil menjadi nomor asli
    final right = original == q.answerIndex; // benar atau salah
    setState(() { // perbarui tampilan
      _selected = pos; // simpan pilihan
      if (right) { // jawaban benar
        _streak++; _correct++; // tambah combo dan benar
        if (_streak > _bestStreak) _bestStreak = _streak; // catat combo terbaik
        final bonus = context.read<CoinProvider>().comboBonus(_streak); // bonus combo
        _earned += 10 + bonus; // 10 koin + bonus
        _gainText = bonus > 0 ? '+${10 + bonus}  COMBO x$_streak' : '+10'; // teks efek
        _gainToken++; // putar efek melayang
      } else { // jawaban salah
        _streak = 0; // combo putus
      }
    });
    if (right) { SystemSound.play(SystemSoundType.click); HapticFeedback.mediumImpact(); } else { HapticFeedback.heavyImpact(); } // umpan balik suara dan getar
    Future.delayed(const Duration(milliseconds: 2400), _next); // beri waktu membaca penjelasan lalu lanjut
  }

  Future<void> _next() async { // pindah soal atau selesai
    if (!mounted || _closing) return; // pastikan layar masih ada
    if (_index == _questions.length - 1) { await _finish(); return; } // soal terakhir
    setState(() { _index++; _selected = null; }); // soal berikutnya
    _timer.forward(from: 0); // timer mulai lagi
  }

  Future<void> _finish() async { // akhir kuis
    _closing = true; // cegah dipanggil dua kali
    final coin = context.read<CoinProvider>(); // penyedia koin
    await coin.addCoins(_earned); // simpan koin
    final old = int.tryParse(await DatabaseHelper.instance.getGameState('best_quiz') ?? '0') ?? 0; // rekor lama
    if (_earned > old) await DatabaseHelper.instance.setGameState('best_quiz', '$_earned'); // simpan rekor baru
    if (!mounted) return; // pastikan layar masih ada
    if (_correct == _questions.length) await unlockWithToast(context, 'kuis_sempurna'); // lencana kuis sempurna
    if (!mounted) return; // pastikan layar masih ada
    if (_bestStreak >= 4) await unlockWithToast(context, 'combo_api'); // lencana combo api
    if (!mounted) return; // pastikan layar masih ada
    await showRewardDialog(context, coins: _earned, message: 'Kuis selesai: $_correct dari ${_questions.length} benar.\nCombo terbaik x$_bestStreak'); // pop-up hadiah
    if (mounted) Navigator.pop(context); // kembali ke menu game
  }

  @override
  Widget build(BuildContext context) { // membangun layar kuis
    final q = _questions[_index]; // soal berjalan
    return Scaffold( // kerangka layar
      appBar: AppBar(title: Text('Soal ${_index + 1} dari ${_questions.length}')), // judul dengan nomor soal
      body: Stack(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 18), // jarak tepi
          child: Column(children: [
            _header(), // cincin waktu, koin, combo
            const SizedBox(height: 10), // jarak
            _comboBanner(), // spanduk combo
            Expanded(child: AnimatedSwitcher( // transisi mulus antar soal
              duration: const Duration(milliseconds: 420), // lama transisi
              switchInCurve: Curves.easeOutCubic, // kurva masuk
              transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: SlideTransition(position: Tween<Offset>(begin: const Offset(0.25, 0), end: Offset.zero).animate(anim), child: child)), // geser dari kanan sambil memudar masuk
              child: _QuestionPage(key: ValueKey(_index), q: q, order: _order[_index], selected: _selected, onAnswer: _answer), // halaman soal
            )),
          ]),
        ),
        Positioned(top: 120, left: 0, right: 0, child: IgnorePointer(child: Center(child: FloatingGain(token: _gainToken, text: _gainText)))), // efek koin melayang
      ]),
    );
  }

  /// Baris atas: cincin waktu, kemajuan soal, dan koin terkumpul.
  Widget _header() { // kepala
    return Row(children: [
      AnimatedBuilder( // cincin waktu bergerak mulus
        animation: _timer, // mengikuti timer
        builder: (_, __) { // dibangun ulang tiap bingkai
          final left = ((1 - _timer.value) * _perQuestion).ceil(); // sisa detik
          final low = left <= 5 && _selected == null; // hampir habis?
          return SizedBox(width: 54, height: 54, child: Stack(alignment: Alignment.center, children: [
            CircularProgressIndicator(value: 1 - _timer.value, strokeWidth: 6, backgroundColor: Colors.black12, color: low ? AppColors.red : AppColors.gold), // cincin waktu
            Text('$left', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: low ? AppColors.red : AppColors.indigo)), // angka detik
          ]));
        },
      ),
      const SizedBox(width: 14), // jarak
      Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: (_index + (_selected != null ? 1 : 0)) / _questions.length, minHeight: 10, color: AppColors.green, backgroundColor: Colors.black12))), // kemajuan soal
      const SizedBox(width: 14), // jarak
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7), // jarak dalam
        decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(20)), // lencana emas
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.monetization_on, size: 18, color: AppColors.indigo), // ikon koin
          const SizedBox(width: 4), // jarak
          AnimatedSwitcher(duration: const Duration(milliseconds: 250), transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c), child: Text('$_earned', key: ValueKey(_earned), style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.indigo))), // angka koin bergulir
        ]),
      ),
    ]);
  }

  /// Spanduk combo yang muncul dari streak 2 dan makin menyala.
  Widget _comboBanner() { // spanduk
    final show = _streak >= 2; // tampil mulai combo 2
    return AnimatedSize( // tinggi menyesuaikan
      duration: const Duration(milliseconds: 250), // lama animasi
      child: show
          ? Container(
              width: double.infinity, // selebar layar
              padding: const EdgeInsets.symmetric(vertical: 6), // jarak dalam
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12), // sudut membulat
                gradient: LinearGradient(colors: _streak >= 4 ? [const Color(0xFFFF6D00), const Color(0xFFD50000)] : [AppColors.gold, const Color(0xFFFF8F00)]), // makin panas makin merah
                boxShadow: [BoxShadow(color: const Color(0xFFFF6D00).withAlpha(120), blurRadius: 10 + _streak * 3.0)], // cahaya makin besar
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                TweenAnimationBuilder<double>(key: ValueKey(_streak), tween: Tween(begin: 0.5, end: 1), duration: const Duration(milliseconds: 400), curve: Curves.elasticOut, builder: (_, s, __) => Transform.scale(scale: s, child: const Icon(Icons.local_fire_department, color: Colors.white))), // api memantul
                const SizedBox(width: 6), // jarak
                Text('COMBO x$_streak${context.read<CoinProvider>().comboBonus(_streak) > 0 ? '  bonus +${context.read<CoinProvider>().comboBonus(_streak)}' : ''}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 0.5)), // teks combo
              ]),
            )
          : const SizedBox(width: double.infinity), // kosong bila belum combo
    );
  }
}

/// Pembungkus nilai kemajuan agar kode builder tetap ringkas.
class _StepValue {
  final double value; // nilai kemajuan 0..1 (bisa sedikit melewati 1 oleh efek memantul)
  const _StepValue(this.value); // konstruktor
}

/// Halaman satu soal: kartu ukiran, pilihan yang masuk bergantian, getar saat salah, penjelasan setelah menjawab.
class _QuestionPage extends StatefulWidget {
  final QuizQuestion q; // soal
  final List<int> order; // urutan pilihan acak
  final int? selected; // posisi pilihan pemain
  final void Function(int) onAnswer; // dipanggil saat pilihan diketuk
  const _QuestionPage({super.key, required this.q, required this.order, required this.selected, required this.onAnswer}); // konstruktor

  @override
  State<_QuestionPage> createState() => _QuestionPageState(); // buat state
}

class _QuestionPageState extends State<_QuestionPage> with TickerProviderStateMixin {
  late final AnimationController _enter = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..forward(); // animasi masuk berurutan
  late final AnimationController _shake = AnimationController(vsync: this, duration: const Duration(milliseconds: 450)); // animasi getar salah
  late final AnimationController _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 500)); // animasi denyut benar

  @override
  void didUpdateWidget(covariant _QuestionPage old) { // dipanggil saat induk memperbarui data
    super.didUpdateWidget(old); // panggil induk
    if (old.selected == null && widget.selected != null) { // baru saja menjawab
      final original = widget.selected == -1 ? -1 : widget.order[widget.selected!]; // nomor asli pilihan
      if (original == widget.q.answerIndex) { _pulse.forward(from: 0); } else { _shake.forward(from: 0); } // denyut bila benar, getar bila salah
    }
  }

  @override
  void dispose() { // dipanggil saat halaman dilepas
    _enter.dispose(); _shake.dispose(); _pulse.dispose(); // hentikan semua animasi
    super.dispose(); // panggil induk
  }

  @override
  Widget build(BuildContext context) { // membangun halaman
    final q = widget.q; // singkatan
    final answered = widget.selected != null; // sudah menjawab?
    return SingleChildScrollView( // aman untuk layar pendek
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        CarvedFrame(child: Column(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3), // jarak dalam
            decoration: BoxDecoration(color: AppColors.green, borderRadius: BorderRadius.circular(20)), // lencana hijau
            child: Text(q.category.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1)), // nama kategori
          ),
          const SizedBox(height: 12), // jarak
          Text(q.question, textAlign: TextAlign.center, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800, height: 1.35, color: AppColors.greenDark)), // pertanyaan
        ])),
        const SizedBox(height: 18), // jarak
        for (int pos = 0; pos < q.options.length; pos++) // satu pilihan per baris
          _option(pos),
        AnimatedSize( // penjelasan muncul mulus
          duration: const Duration(milliseconds: 300), // lama animasi
          child: answered
              ? Container(
                  margin: const EdgeInsets.only(top: 6), // jarak atas
                  padding: const EdgeInsets.all(14), // jarak dalam
                  decoration: BoxDecoration(color: AppColors.indigo, borderRadius: BorderRadius.circular(14)), // kartu indigo
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Icon(Icons.lightbulb, color: AppColors.gold, size: 20), // ikon lampu
                    const SizedBox(width: 10), // jarak
                    Expanded(child: Text(widget.selected == -1 ? 'Waktu habis. ${q.explanation}' : q.explanation, style: const TextStyle(color: Colors.white, height: 1.4, fontSize: 13))), // penjelasan
                  ]),
                )
              : const SizedBox(width: double.infinity), // kosong sebelum menjawab
        ),
      ]),
    );
  }

  /// Satu tombol pilihan dengan animasi masuk berurutan, getar, dan denyut.
  Widget _option(int pos) { // pos = posisi tampil
    final q = widget.q; // singkatan
    final original = widget.order[pos]; // nomor asli
    final answered = widget.selected != null; // sudah menjawab?
    final isCorrect = original == q.answerIndex; // pilihan benar?
    final isChosen = widget.selected == pos; // pilihan pemain?
    Color bg = Colors.white; // warna awal
    Color border = Colors.black12; // warna tepi awal
    if (answered && isCorrect) { bg = const Color(0xFFB9E6C9); border = AppColors.green; } // jawaban benar: hijau
    if (answered && isChosen && !isCorrect) { bg = const Color(0xFFF3C0B8); border = AppColors.red; } // pilihan salah: merah
    final stepCurve = Interval(0.12 * pos, 0.12 * pos + 0.5, curve: Curves.easeOutBack); // kurva masuk tiap pilihan (bergiliran)
    return AnimatedBuilder(
      animation: Listenable.merge([_enter, _shake, _pulse]), // gabungkan semua animasi
      builder: (_, child) {
        final step = _StepValue(stepCurve.transform(_enter.value)); // nilai kemajuan pilihan ini
        final shakeX = (isChosen && !isCorrect) ? math.sin(_shake.value * math.pi * 6) * 8 * (1 - _shake.value) : 0.0; // getar mengecil
        final pop = (answered && isCorrect) ? 1 + 0.05 * math.sin(_pulse.value * math.pi) : 1.0; // denyut membesar sebentar
        return Opacity(
          opacity: step.value.clamp(0.0, 1.0).toDouble(), // memudar masuk
          child: Transform.translate(offset: Offset(shakeX + (1 - step.value) * 40, 0), child: Transform.scale(scale: pop, child: child)), // geser dari kanan, getar, denyut
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10), // jarak antar pilihan
        child: AnimatedContainer( // warna berubah mulus
          duration: const Duration(milliseconds: 250), // lama perubahan
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14), border: Border.all(color: border, width: 1.6)), // kotak pilihan
          child: InkWell(
            borderRadius: BorderRadius.circular(14), // efek ketuk mengikuti sudut
            onTap: answered ? null : () => widget.onAnswer(pos), // nonaktif setelah menjawab
            child: Padding(
              padding: const EdgeInsets.all(14), // jarak dalam
              child: Row(children: [
                CircleAvatar(radius: 14, backgroundColor: AppColors.green.withAlpha(30), child: Text(String.fromCharCode(65 + pos), style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.greenDark, fontSize: 13))), // huruf A-D
                const SizedBox(width: 12), // jarak
                Expanded(child: Text(q.options[original], style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w600))), // teks pilihan
                if (answered && isCorrect) const Icon(Icons.check_circle, color: AppColors.green), // tanda benar
                if (answered && isChosen && !isCorrect) const Icon(Icons.cancel, color: AppColors.red), // tanda salah
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
