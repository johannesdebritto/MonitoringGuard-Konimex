import 'package:sqflite/sqflite.dart';
import 'init_db.dart'; // Pastikan ini mengarah ke file InitDb Anda

class TugasUnitHelper {
  static Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE tugas_unit (
        id_tugas INTEGER PRIMARY KEY AUTOINCREMENT,
        id_unit INTEGER NOT NULL,
        nama_tugas TEXT NOT NULL,
        id_status INTEGER DEFAULT 1
      )
    ''');
  }

  static Future<int> insertTugasUnit(Map<String, dynamic> data) async {
    final db = await InitDb.getDatabase();
    return await db.insert('tugas_unit', data);
  }

  static Future<List<Map<String, dynamic>>> getAllTugasUnit() async {
    final db = await InitDb.getDatabase();
    return await db.query('tugas_unit');
  }
}
