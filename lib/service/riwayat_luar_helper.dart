import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';
import 'init_db.dart'; // import initDb singleton

class RiwayatLuarHelper {
  // Fungsi createTable tetap di sini
  static Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE riwayat_luar (
        id_riwayat INTEGER PRIMARY KEY AUTOINCREMENT,
        id_unit INTEGER NOT NULL,
        id_patroli INTEGER NOT NULL,
        id_unit_kerja INTEGER NOT NULL,
        id_anggota INTEGER NOT NULL,
        id_status_luar INTEGER,
        hari TEXT NOT NULL,
        tanggal TEXT NOT NULL,
        waktu_mulai_luar TEXT,
        waktu_selesai_luar TEXT
      )
    ''');
  }

  // Insert data ke tabel riwayat_luar
  static Future<int> insertRiwayatLuar(Map<String, dynamic> data) async {
    final db = await InitDb.getDatabase();
    return await db.insert('riwayat_luar', data);
  }

  // Ambil semua data dari riwayat_luar
  static Future<List<Map<String, dynamic>>> getAllRiwayatLuar() async {
    final db = await InitDb.getDatabase();
    return await db.query('riwayat_luar');
  }

  // Ambil ID unit dari satu baris pertama
  static Future<int> getIdUnit() async {
    final db = await InitDb.getDatabase();
    final result =
        await db.query('riwayat_luar', columns: ['id_unit'], limit: 1);
    return result.isNotEmpty ? (result.first['id_unit'] as int) : 0;
  }

  // Submit Riwayat Luar (validasi tugas & update status)
  static Future<void> submitRiwayatLuar() async {
    final db = await InitDb.getDatabase();

    final List<Map<String, dynamic>> riwayatResult = await db.rawQuery(
        'SELECT id_riwayat, id_unit FROM riwayat_luar ORDER BY id_riwayat DESC LIMIT 1');

    if (riwayatResult.isEmpty)
      throw Exception('Tidak ada data di riwayat_luar');

    final int idRiwayat = riwayatResult.first['id_riwayat'] as int;
    final int idUnit = riwayatResult.first['id_unit'] as int;

    final List<Map<String, dynamic>> tugasResult = await db.rawQuery(
        'SELECT COUNT(*) AS tugasSelesai FROM detail_riwayat_luar WHERE id_riwayat = ? AND id_unit = ? AND id_status = 2',
        [idRiwayat, idUnit]);

    final int tugasSelesai = tugasResult.first['tugasSelesai'] as int? ?? 0;

    if (tugasSelesai < 5) {
      throw Exception(
          'Selesaikan semua tugas sebelum submit, masih kurang ${5 - tugasSelesai} tugas');
    }

    final now = DateTime.now();
    final waktuWib = DateFormat('HH:mm:ss').format(now);

    await db.update(
      'riwayat_luar',
      {
        'waktu_selesai_luar': waktuWib,
        'id_status_luar': 2,
      },
      where: 'id_riwayat = ?',
      whereArgs: [idRiwayat],
    );
  }

// Ambil riwayat luar beserta nama unit berdasarkan id_unit dan id_riwayat
  static Future<List<Map<String, dynamic>>> getRiwayatLuarByUnitDanRiwayat(
      String idUnit, String idRiwayat) async {
    final db = await InitDb.getDatabase();

    int parsedIdUnit = int.tryParse(idUnit) ?? -1;
    int parsedIdRiwayat = int.tryParse(idRiwayat) ?? -1;

    return await db.rawQuery('''
    SELECT rl.*, u.nama_unit
    FROM riwayat_luar rl
    JOIN unit u ON rl.id_unit = u.id_unit
    WHERE rl.id_unit = ? AND rl.id_riwayat = ?
  ''', [parsedIdUnit, parsedIdRiwayat]);
  }
}
