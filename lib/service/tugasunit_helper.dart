import 'package:sqflite/sqflite.dart';
import 'init_db.dart';

class TugasUnitHelper {
  static Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE tugas_unit (
        id_tugas INTEGER PRIMARY KEY AUTOINCREMENT,
        id_unit INTEGER,
        nama_tugas TEXT
      )
    ''');

    List<Map<String, dynamic>> dataTugas = [
      {'id_unit': 1, 'nama_tugas': "Pengecekan Kantin"},
      {'id_unit': 1, 'nama_tugas': "Pengecekan Ruang IT"},
      {'id_unit': 1, 'nama_tugas': "Pengecekan Toilet"},
      {'id_unit': 1, 'nama_tugas': "Pengecekan Gudang"},
      {'id_unit': 1, 'nama_tugas': "Pengecekan Parkiran"},
      {'id_unit': 2, 'nama_tugas': "Pengecekan Ruang Rapat"},
      {'id_unit': 2, 'nama_tugas': "Pengecekan Ruang Server"},
      {'id_unit': 2, 'nama_tugas': "Pengecekan Lantai 2"},
      {'id_unit': 2, 'nama_tugas': "Pengecekan Ruang Security"},
      {'id_unit': 2, 'nama_tugas': "Pengecekan Lobby"},
      {'id_unit': 3, 'nama_tugas': "Pengecekan Ruang Direktur"},
      {'id_unit': 3, 'nama_tugas': "Pengecekan Ruang Produksi"},
      {'id_unit': 3, 'nama_tugas': "Pengecekan Ruang Meeting"},
      {'id_unit': 3, 'nama_tugas': "Pengecekan Toilet Umum"},
      {'id_unit': 3, 'nama_tugas': "Pengecekan Tangga Darurat"},
      {'id_unit': 4, 'nama_tugas': "Pengecekan Ruang HRD"},
      {'id_unit': 4, 'nama_tugas': "Pengecekan Ruang Keuangan"},
      {'id_unit': 4, 'nama_tugas': "Pengecekan Ruang Arsip"},
      {'id_unit': 4, 'nama_tugas': "Pengecekan Pantry"},
      {'id_unit': 4, 'nama_tugas': "Pengecekan Area Parkir"},
      {'id_unit': 5, 'nama_tugas': "Pengecekan Mesin Produksi"},
      {'id_unit': 5, 'nama_tugas': "Pengecekan Ruang Maintenance"},
      {'id_unit': 5, 'nama_tugas': "Pengecekan Ruang Operator"},
      {'id_unit': 5, 'nama_tugas': "Pengecekan Dapur Karyawan"},
      {'id_unit': 5, 'nama_tugas': "Pengecekan Area Loading Dock"},
    ];

    Batch batch = db.batch();
    for (var tugas in dataTugas) {
      batch.insert('tugas_unit', tugas);
    }
    await batch.commit(noResult: true);
  }

  static Future<List<Map<String, dynamic>>> getAllTugasUnit() async {
    final db = await InitDb.getDatabase();
    return await db.query('tugas_unit');
  }
}
