// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';

// class DBHelper {
//   static Database? _database;

//   static Future<Database> initDb() async {
//     if (_database != null) return _database!;
//     String path = join(await getDatabasesPath(), 'app_local.db');

//     _database = await openDatabase(
//       path,
//       version: 2, // Naikkan versi database

//       onCreate: (db, version) async {
//         // Tabel riwayat_luar
//         await db.execute(''' 
//           CREATE TABLE riwayat_luar (
//             id_riwayat INTEGER PRIMARY KEY AUTOINCREMENT,
//             id_unit INTEGER NOT NULL,
//             id_patroli INTEGER NOT NULL,
//             id_unit_kerja INTEGER NOT NULL,
//             id_anggota INTEGER NOT NULL,
//             id_status_luar INTEGER,
//             hari TEXT NOT NULL,
//             tanggal TEXT NOT NULL,
//             waktu_mulai_luar TEXT,
//             waktu_selesai_luar TEXT
//           )
//         ''');

//         // Tabel riwayat_dalam
//         await db.execute(''' 
//           CREATE TABLE riwayat_dalam (
//             id_riwayat INTEGER PRIMARY KEY AUTOINCREMENT,
//             id_unit INTEGER NOT NULL,
//             id_patroli INTEGER NOT NULL,
//             id_unit_kerja INTEGER NOT NULL,
//             id_anggota INTEGER NOT NULL,
//             id_status_dalam TEXT,
//             hari TEXT NOT NULL,
//             tanggal TEXT NOT NULL,
//             waktu_mulai_dalam TEXT,
//             waktu_selesai_dalam TEXT
//           )
//         ''');

//         // Tabel detail_riwayat_luar
//         await db.execute(''' 
//           CREATE TABLE detail_riwayat_luar (
//             id_rekap INTEGER PRIMARY KEY AUTOINCREMENT,
//             id_tugas INTEGER NOT NULL,
//             id_anggota INTEGER NOT NULL,
//             id_status INTEGER NOT NULL,
//             id_riwayat INTEGER NOT NULL,
//             id_unit INTEGER NOT NULL,
//             keterangan_masalah TEXT,
//             tanggal_selesai TEXT,
//             jam_selesai TEXT,
//             tanggal_gagal TEXT,
//             jam_gagal TEXT
//           )
//         ''');

//         // Tabel detail_riwayat_dalam
//         await db.execute(''' 
//           CREATE TABLE IF NOT EXISTS detail_riwayat_dalam (
//             id_rekap INTEGER PRIMARY KEY AUTOINCREMENT,
//             nama_anggota TEXT NOT NULL,
//             id_status INTEGER NOT NULL,
//             bagian TEXT,
//             keterangan_masalah TEXT,
//             tanggal_selesai TEXT,
//             jam_selesai TEXT,
//             id_riwayat INTEGER NOT NULL
//           )
//         ''');

//         // Tabel tugas_unit
//         await db.execute('''
//   CREATE TABLE tugas_unit (
//     id_tugas INTEGER PRIMARY KEY AUTOINCREMENT,
//     id_unit INTEGER NOT NULL,
//     nama_tugas TEXT NOT NULL,
//     id_status INTEGER DEFAULT 1
//   )
// ''');
//       },

//       // onUpgrade digunakan untuk memperbarui struktur tabel saat versi database berubah
//       onUpgrade: (db, oldVersion, newVersion) async {
//         if (oldVersion < 2) {
//           // Membuat tabel baru tanpa kolom id_anggota
//           await db.execute(''' 
//             CREATE TABLE detail_riwayat_dalam_new (
//               id_rekap INTEGER PRIMARY KEY AUTOINCREMENT,
//               nama_anggota TEXT NOT NULL,
//               id_status INTEGER NOT NULL,
//               bagian TEXT,
//               keterangan_masalah TEXT,
//               tanggal_selesai TEXT,
//               jam_selesai TEXT,
//               id_riwayat INTEGER NOT NULL
//             );
//           ''');

//           // Salin data dari tabel lama ke tabel baru
//           await db.execute(''' 
//             INSERT INTO detail_riwayat_dalam_new (id_rekap, nama_anggota, id_status, bagian, keterangan_masalah, tanggal_selesai, jam_selesai, id_riwayat)
//             SELECT id_rekap, nama_anggota, id_status, bagian, keterangan_masalah, tanggal_selesai, jam_selesai, id_riwayat
//             FROM detail_riwayat_dalam;
//           ''');

//           // Hapus tabel lama
//           await db.execute('DROP TABLE detail_riwayat_dalam');

//           // Ganti nama tabel baru menjadi tabel lama
//           await db.execute(
//               'ALTER TABLE detail_riwayat_dalam_new RENAME TO detail_riwayat_dalam');
//         }
//       },
//     );

//     return _database!;
//   }

//   // === RIWAYAT LUAR ===
//   static Future<int> insertRiwayatLuar(Map<String, dynamic> data) async {
//     final db = await initDb();
//     return await db.insert('riwayat_luar', data);
//   }

//   static Future<List<Map<String, dynamic>>> getAllRiwayatLuar() async {
//     final db = await initDb();
//     return await db.query('riwayat_luar');
//   }

//   // === RIWAYAT DALAM ===
//   static Future<int> insertRiwayatDalam(Map<String, dynamic> data) async {
//     final db = await initDb();
//     return await db.insert('riwayat_dalam', data);
//   }

//   static Future<List<Map<String, dynamic>>> getAllRiwayatDalam() async {
//     final db = await initDb();
//     return await db.query('riwayat_dalam');
//   }

//   static Future<Map<String, dynamic>> getRiwayatDalamById(int idRiwayat) async {
//     final db = await initDb();
//     final result = await db.query(
//       'riwayat_dalam',
//       where: 'id_riwayat = ?',
//       whereArgs: [idRiwayat],
//     );
//     return result.isNotEmpty
//         ? result.first
//         : {}; // Mengembalikan data pertama atau map kosong jika tidak ditemukan
//   }

//   static Future<int> insertDetailRiwayatLuar(Map<String, dynamic> data) async {
//     final db = await initDb();

//     // Ambil ID terakhir dari tabel riwayat_luar
//     final List<Map<String, dynamic>> resultRiwayat = await db.rawQuery(
//       'SELECT id_riwayat, id_unit FROM riwayat_luar ORDER BY id_riwayat DESC LIMIT 1',
//     );

//     if (resultRiwayat.isNotEmpty) {
//       final int latestRiwayatId = resultRiwayat.first['id_riwayat'];
//       final int latestUnitId =
//           resultRiwayat.first['id_unit']; // Ambil id_unit dari riwayat_luar

//       // Tambahkan id_riwayat dan id_unit ke data yang akan dimasukkan ke detail_riwayat_luar
//       data['id_riwayat'] = latestRiwayatId;
//       data['id_unit'] = latestUnitId;

//       // Insert ke detail_riwayat_luar
//       return await db.insert('detail_riwayat_luar', data);
//     } else {
//       throw Exception('Tidak ada data di riwayat_luar');
//     }
//   }

//   static Future<List<Map<String, dynamic>>> getAllDetailRiwayatLuar() async {
//     final db = await initDb();
//     return await db.query('detail_riwayat_luar');
//   }

//   static Future<int> getIdUnit() async {
//     final db = await initDb();
//     final result =
//         await db.query('riwayat_luar', columns: ['id_unit'], limit: 1);
//     return result.isNotEmpty ? (result.first['id_unit'] as int) : 0;
//   }

// // Ambil data dari detail_riwayat_luar berdasarkan id_tugas dan id_riwayat
//   static Future<int?> getStatusFromLatestRiwayat(String idTugas) async {
//     final db = await initDb();

//     final latestRiwayatResult = await db.rawQuery(
//       'SELECT id_riwayat FROM riwayat_luar ORDER BY id_riwayat DESC LIMIT 1',
//     );

//     if (latestRiwayatResult.isEmpty) {
//       print("🚨 [DB] Tidak ada riwayat dalam riwayat_luar");
//       return 0; // default jika tidak ada riwayat
//     }

//     int latestRiwayatId = latestRiwayatResult.first['id_riwayat'] as int;
//     print("🔍 [DB] Riwayat terbaru ID: $latestRiwayatId");

//     final statusResult = await db.query(
//       'detail_riwayat_luar',
//       columns: ['id_status'],
//       where: 'id_tugas = ? AND id_riwayat = ?',
//       whereArgs: [idTugas, latestRiwayatId],
//     );

//     if (statusResult.isNotEmpty) {
//       print(
//           "✅ [DB] Status ditemukan | id_status: ${statusResult.first['id_status']}");
//       return statusResult.first['id_status'] as int;
//     }

//     print(
//         "⚠️ [DB] Tidak ditemukan status untuk idTugas: $idTugas dan idRiwayat: $latestRiwayatId");
//     return 0; // default kalau tidak ada status
//   }

// //ambil data dari tanggal dll
//   static Future<Map<String, dynamic>?> getRiwayatDetails(String idTugas) async {
//     final db = await initDb();

//     // Mengambil riwayat terbaru
//     final latestRiwayatResult = await db.rawQuery(
//       'SELECT id_riwayat FROM riwayat_luar ORDER BY id_riwayat DESC LIMIT 1',
//     );

//     if (latestRiwayatResult.isEmpty) {
//       print("🚨 [DB] Tidak ada riwayat dalam riwayat_luar");
//       return null; // Jika tidak ada riwayat
//     }

//     int latestRiwayatId = latestRiwayatResult.first['id_riwayat'] as int;
//     print("🔍 [DB] Riwayat terbaru ID: $latestRiwayatId");

//     // Mengambil detail riwayat berdasarkan id_tugas dan id_riwayat
//     final riwayatDetailsResult = await db.query(
//       'detail_riwayat_luar',
//       columns: [
//         'tanggal_selesai',
//         'jam_selesai',
//         'keterangan_masalah',
//         'jam_gagal',
//         'tanggal_gagal'
//       ],
//       where: 'id_tugas = ? AND id_riwayat = ?',
//       whereArgs: [idTugas, latestRiwayatId],
//     );

//     if (riwayatDetailsResult.isNotEmpty) {
//       print("✅ [DB] Riwayat details ditemukan");

//       return {
//         'tanggal_selesai': riwayatDetailsResult.first['tanggal_selesai'],
//         'jam_selesai': riwayatDetailsResult.first['jam_selesai'],
//         'keterangan_masalah': riwayatDetailsResult.first['keterangan_masalah'],
//         'jam_gagal': riwayatDetailsResult.first['jam_gagal'],
//         'tanggal_gagal': riwayatDetailsResult.first['tanggal_gagal'],
//       };
//     }

//     print(
//         "⚠️ [DB] Tidak ditemukan detail riwayat untuk idTugas: $idTugas dan idRiwayat: $latestRiwayatId");
//     return null; // Default jika tidak ada detail
//   }

// //submit detail_riwyaat_luar
//   static Future<void> submitRiwayatLuar() async {
//     final db = await initDb();

//     // Ambil id_riwayat terbaru
//     final List<Map<String, dynamic>> riwayatResult = await db.rawQuery(
//         'SELECT id_riwayat, id_unit FROM riwayat_luar ORDER BY id_riwayat DESC LIMIT 1');

//     if (riwayatResult.isEmpty)
//       throw Exception('Tidak ada data di riwayat_luar');

//     final int idRiwayat = riwayatResult.first['id_riwayat'];
//     final int idUnit = riwayatResult.first['id_unit'];

//     print("🧪 [submit] idRiwayat: $idRiwayat, idUnit: $idUnit");

//     // Cek jumlah tugas dengan id_status = 2 untuk id_riwayat dan id_unit yang sama
//     final List<Map<String, dynamic>> tugasResult = await db.rawQuery(
//         'SELECT COUNT(*) AS tugasSelesai FROM detail_riwayat_luar WHERE id_riwayat = ? AND id_unit = ? AND id_status = 2',
//         [idRiwayat, idUnit]);

//     final int tugasSelesai = tugasResult.first['tugasSelesai'] ?? 0;

//     print("📊 [submit] tugasSelesai: $tugasSelesai");

//     // Cek apakah sudah ada 5 tugas selesai
//     if (tugasSelesai < 5) {
//       throw Exception(
//           'Selesaikan semua tugas sebelum submit, masih kurang ${5 - tugasSelesai} tugas');
//     }

//     // Ambil waktu lokal WIB
//     final now = DateTime.now();
//     final waktuWib =
//         "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";

//     // Update riwayat_luar jadi selesai
//     await db.update(
//       'riwayat_luar',
//       {
//         'waktu_selesai_luar': waktuWib,
//         'id_status_luar': 2,
//       },
//       where: 'id_riwayat = ?',
//       whereArgs: [idRiwayat],
//     );

//     print("✅ [submit] Riwayat berhasil disubmit offline pada $waktuWib");
//   }

// // Get Riwayat Luar dengan debug log dan konversi ke int
//   static Future<List<Map<String, dynamic>>> getRiwayatLuarByUnitDanRiwayat(
//       String idUnit, String idRiwayat) async {
//     final db = await initDb();

//     // Tampilkan parameter yang diterima
//     print("🔍 Parameter masuk - idUnit: '$idUnit', idRiwayat: '$idRiwayat'");

//     // Tampilkan semua isi tabel untuk debugging
//     final allData = await db.query('riwayat_luar');
//     print("📋 Semua data di tabel riwayat_luar:");
//     for (var item in allData) {
//       print(item);
//     }

//     // Konversi String ke int agar cocok dengan format data di SQLite
//     int parsedIdUnit = int.tryParse(idUnit) ?? -1;
//     int parsedIdRiwayat = int.tryParse(idRiwayat) ?? -1;

//     // Jalankan query filtered
//     final result = await db.query(
//       'riwayat_luar',
//       where: 'id_unit = ? AND id_riwayat = ?',
//       whereArgs: [parsedIdUnit, parsedIdRiwayat],
//     );

//     print("📦 Hasil Query Filtered: $result");

//     return result;
//   }

// //get all detail riwayat luar
//   static Future<List<Map<String, dynamic>>> getDetailRiwayatLuarOffline(
//       int idUnit, int idRiwayat) async {
//     final db = await initDb();

//     print("🔍 [DB] Parameter masuk - idUnit: $idUnit, idRiwayat: $idRiwayat");

//     // Debug: tampilkan semua data dari tabel
//     final allData = await db.query('detail_riwayat_luar');
//     print("📋 [DB] Semua data di tabel detail_riwayat_luar:");
//     for (var item in allData) {
//       print(item);
//     }

//     // Jalankan query dengan filter
//     final result = await db.query(
//       'detail_riwayat_luar',
//       where: 'id_unit = ? AND id_riwayat = ?',
//       whereArgs: [idUnit, idRiwayat],
//     );

//     print("📦 [DB] Hasil Query Filtered: $result");

//     return result;
//   }

//   // == Detail Riwayat Dalam == //
//   static Future<int> insertDetailRiwayatDalam(Map<String, dynamic> data) async {
//     final db = await initDb();
//     return await db.insert('detail_riwayat_dalam', data);
//   }

//   static Future<List<Map<String, dynamic>>> getAllDetailRiwayatDalam() async {
//     ////////////////////////////////////////////
//     final db = await initDb();
//     return await db.query('detail_riwayat_dalam');
//   }

//   // == Detail Riwayat Dalam by ID == //
//   static Future<List<Map<String, dynamic>>> getDetailRiwayatDalamById(
//       int idRiwayat) async {
//     final db = await initDb();
//     return await db.query(
//       'detail_riwayat_dalam',
//       where: 'id_riwayat = ?',
//       whereArgs: [idRiwayat],
//     );
//   }

//   // Update data riwayat_dalam berdasarkan id_riwayat
//   static Future<int> updateRiwayatDalam(
//       int idRiwayat, Map<String, dynamic> data) async {
//     final db = await initDb();
//     return await db.update(
//       'riwayat_dalam',
//       data,
//       where: 'id_riwayat = ?',
//       whereArgs: [idRiwayat],
//     );
//   }

//   // === TUGAS UNIT ===
//   static Future<int> insertTugasUnit(Map<String, dynamic> data) async {
//     final db = await initDb();
//     return await db.insert('tugas_unit', data);
//   }

//   static Future<List<Map<String, dynamic>>> getAllTugasUnit() async {
//     final db = await initDb();
//     return await db.query('tugas_unit');
//   }
// }
