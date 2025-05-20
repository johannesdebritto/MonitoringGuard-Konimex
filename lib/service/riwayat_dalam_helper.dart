import 'package:sqflite/sqflite.dart';
import 'init_db.dart'; // import dari init_db.dart

class RiwayatDalamHelper {
  // Fungsi createTable tetap di sini
  static Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE riwayat_dalam (
        id_riwayat INTEGER PRIMARY KEY AUTOINCREMENT,
        id_unit INTEGER NOT NULL,
        id_patroli INTEGER NOT NULL,
        id_unit_kerja INTEGER NOT NULL,
        id_anggota INTEGER NOT NULL,
        id_status_dalam TEXT,
        hari TEXT NOT NULL,
        tanggal TEXT NOT NULL,
        waktu_mulai_dalam TEXT,
        waktu_selesai_dalam TEXT
      )
    ''');
  }

  // Insert data ke tabel riwayat_dalam
  static Future<int> insertRiwayatDalam(Map<String, dynamic> data) async {
    final db = await InitDb.getDatabase();
    return await db.insert('riwayat_dalam', data);
  }

  // Ambil semua data dari riwayat_dalam
  static Future<List<Map<String, dynamic>>> getAllRiwayatDalam() async {
    final db = await InitDb.getDatabase();
    return await db.query('riwayat_dalam');
  }

  // Ambil satu data berdasarkan id_riwayat
  static Future<Map<String, dynamic>> getRiwayatDalamById(int idRiwayat) async {
    final db = await InitDb.getDatabase();
    final result = await db.query(
      'riwayat_dalam',
      where: 'id_riwayat = ?',
      whereArgs: [idRiwayat],
    );
    return result.isNotEmpty ? result.first : {};
  }

  // Update data pada tabel riwayat_dalam
  static Future<int> updateRiwayatDalam(
      int idRiwayat, Map<String, dynamic> data) async {
    final db = await InitDb.getDatabase();
    return await db.update(
      'riwayat_dalam',
      data,
      where: 'id_riwayat = ?',
      whereArgs: [idRiwayat],
    );
  }
}
