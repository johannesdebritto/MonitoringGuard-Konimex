import 'package:sqflite/sqflite.dart';
import 'init_db.dart';

class UnitHelper {
  static Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE unit (
        id_unit INTEGER PRIMARY KEY,
        nama_unit TEXT NOT NULL
      )
    ''');

    // Insert data awal 5 unit
    Batch batch = db.batch();
    for (int i = 1; i <= 5; i++) {
      batch.insert('unit', {
        'id_unit': i,
        'nama_unit': 'Gedung Farmasi $i',
      });
    }
    await batch.commit(noResult: true);
  }

  static Future<List<Map<String, dynamic>>> getAllUnits() async {
    final db = await InitDb.getDatabase();
    return await db.query('unit');
  }
}
