import 'package:sqflite/sqflite.dart';
import 'init_db.dart'; // import init_db.dart yang sudah dibuat

class DetailRiwayatDalamHelper {
  // Membuat tabel tetap di sini supaya bisa dipanggil saat onCreate
  static Future<void> createTable(Database db) async {
    await db.execute(''' 
      CREATE TABLE IF NOT EXISTS detail_riwayat_dalam (
        id_rekap INTEGER PRIMARY KEY AUTOINCREMENT,
        id_anggota INTEGER NOT NULL,          -- diubah dari nama_anggota TEXT menjadi id_anggota INTEGER
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
