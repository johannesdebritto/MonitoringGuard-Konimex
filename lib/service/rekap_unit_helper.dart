import 'package:sqflite/sqflite.dart';
import 'init_db.dart'; // Pastikan ini benar mengarah ke file InitDb Anda

class RekapUnitHelper {
  static Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE rekap_unit (
        id_rekap INTEGER PRIMARY KEY AUTOINCREMENT,
        id_unit INTEGER NOT NULL,
        nama_rekap TEXT NOT NULL,
        id_status INTEGER DEFAULT 1
      )
    ''');
  }

  static Future<int> insertRekapUnit(Map<String, dynamic> data) async {
    final db = await InitDb.getDatabase();
    return await db.insert('rekap_unit', data);
  }

  static Future<List<Map<String, dynamic>>> getAllRekapUnit() async {
    final db = await InitDb.getDatabase();
    return await db.query('rekap_unit');
  }
}
