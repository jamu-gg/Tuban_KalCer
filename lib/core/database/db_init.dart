export 'db_init_stub.dart' // dipakai di Android, iOS, dan platform lain
    if (dart.library.js_interop) 'db_init_web.dart'; // dipakai otomatis saat aplikasi dikompilasi untuk web
