import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart'; // sqflite versi web (SQLite berbasis WebAssembly)
import 'package:sqflite/sqflite.dart';

/// Versi untuk web (Chrome): mengganti mesin database bawaan dengan versi web.
void initDatabaseFactory() {
  databaseFactory = databaseFactoryFfiWeb; // semua openDatabase() berikutnya memakai SQLite web; data tersimpan di IndexedDB browser
}
