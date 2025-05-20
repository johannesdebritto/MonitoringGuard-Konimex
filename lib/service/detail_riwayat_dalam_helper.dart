import 'package:sqflite/sqflite.dart';
import 'init_db.dart'; // import init_db.dart yang sudah dibuat

class DetailRiwayatDalamHelper {
  // Tidak perlu initDb lagi di sini karena sudah di init_db.dart

  // Membuat tabel tetap di sini supaya bisa dipanggil saat onCreate
  static Future<void> createTable(Database db) async {
    await db.execute(''' 
      CREATE TABLE IF NOT EXISTS detail_riwayat_dalam (
        id_rekap INTEGER PRIMARY KEY AUTOINCREMENT,
        nama_anggota TEXT NOT NULL,
        id_status INTEGER NOT NULL,
        bagian TEXT,
        keterangan_masalah TEXT,
        tanggal_selesai TEXT,
        jam_selesai TEXT,
        id_riwayat INTEGER NOT NULL
      )
    ''');
  }

  // Insert data, ambil db dari InitDb
  static Future<int> insertDetailRiwayatDalam(Map<String, dynamic> data) async {
    final db = await InitDb.getDatabase();
    return await db.insert('detail_riwayat_dalam', data);
  }

  // Ambil semua data
  static Future<List<Map<String, dynamic>>> getAllDetailRiwayatDalam() async {
    final db = await InitDb.getDatabase();
    return await db.query('detail_riwayat_dalam');
  }

  // Ambil data berdasarkan id_riwayat
  static Future<List<Map<String, dynamic>>> getDetailRiwayatDalamById(
      int idRiwayat) async {
    final db = await InitDb.getDatabase();
    return await db.query(
      'detail_riwayat_dalam',
      where: 'id_riwayat = ?',
      whereArgs: [idRiwayat],
    );
  }
}
