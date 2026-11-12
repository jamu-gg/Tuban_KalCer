# Tuban KalCer

Aplikasi edukasi budaya Tuban dengan gamifikasi (Flutter + SQLite).

## Cara menjalankan
1. Pasang Flutter 3.22 atau lebih baru.
2. Di folder ini jalankan `flutter create .` (membuat folder android/ dan ios/, berkas lib/ tidak ditimpa).
3. `flutter pub get`
4. `flutter run`

## Menjalankan di Chrome (web)
Sekali saja setelah `flutter pub get`, jalankan `dart run sqflite_common_ffi_web:setup` (menyalin sqlite3.wasm dan sqflite_sw.js ke folder web/), lalu `flutter run -d chrome`.

Catatan: kode ditulis tanpa dijalankan di emulator; bila ada galat kompilasi kecil, perbaiki sesuai pesan Flutter.
# Tuban_KalCer
