import 'dart:async'; // Timer
import 'package:flutter/foundation.dart'; // ChangeNotifier

/// Pengendali narasi Story Card.
/// Saat ini narasi disimulasikan dengan penanda paragraf yang berjalan sesuai panjang teks (tanpa suara),
/// sehingga tidak butuh paket tambahan. Untuk suara sungguhan, ganti isi [_speakCurrent] dengan flutter_tts
/// (panggil tts.speak(paragraf) lalu, pada setCompletionHandler, panggil [_advance]).
class NarrationController extends ChangeNotifier {
  final List<String> paragraphs; // paragraf yang dinarasikan
  NarrationController(this.paragraphs); // konstruktor

  Timer? _timer; // pewaktu
  bool _playing = false; // sedang berjalan?
  bool _finished = false; // sudah selesai semua paragraf?
  int _index = 0; // paragraf berjalan
  double _elapsed = 0; // detik berjalan pada paragraf ini

  bool get playing => _playing; // getter status
  bool get finished => _finished; // getter selesai
  int get index => _index; // getter paragraf berjalan
  double get paragraphProgress => (_elapsed / _durationOf(_index)).clamp(0.0, 1.0).toDouble(); // kemajuan paragraf ini 0..1
  double get overall => _finished ? 1 : ((_index + paragraphProgress) / paragraphs.length).clamp(0.0, 1.0).toDouble(); // kemajuan total 0..1

  double _durationOf(int i) => (paragraphs[i].length * 0.055).clamp(2.0, 12.0).toDouble(); // lama paragraf (detik) menurut panjang teks

  void play() { // mulai atau lanjut
    if (_finished) { _finished = false; _index = 0; _elapsed = 0; } // ulang dari awal bila sudah selesai
    _playing = true; // tandai berjalan
    _speakCurrent(); // mulai membacakan paragraf (titik sambung ke TTS)
    _timer?.cancel(); // hentikan pewaktu lama
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) => _tick()); // detak 100 ms
    notifyListeners(); // beri tahu UI
  }

  void pause() { // jeda
    _playing = false; // tandai berhenti
    _timer?.cancel(); // hentikan pewaktu
    notifyListeners(); // beri tahu UI
  }

  void _speakCurrent() {} // titik sambung: panggil TTS untuk paragraphs[_index] di sini

  void _tick() { // satu detak
    _elapsed += 0.1; // tambah 0,1 detik
    if (_elapsed >= _durationOf(_index)) _advance(); // paragraf selesai
    notifyListeners(); // perbarui UI
  }

  void _advance() { // pindah paragraf
    _elapsed = 0; // atur ulang waktu paragraf
    if (_index >= paragraphs.length - 1) { // paragraf terakhir selesai
      _finished = true; _playing = false; _timer?.cancel(); // selesai total
    } else {
      _index++; // paragraf berikutnya
      _speakCurrent(); // bacakan paragraf baru
    }
  }

  @override
  void dispose() { // dipanggil saat dilepas
    _timer?.cancel(); // pastikan pewaktu berhenti
    super.dispose(); // panggil induk
  }
}
