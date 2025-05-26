import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'init_db.dart'; // import init_db.dart yang sudah dibuat

class DetailRiwayatLuarHelper {
  // Fungsi createTable tetap di sini
  static Future<void> createTable(Database db) async {
    await db.execute(''' 
      CREATE TABLE detail_riwayat_luar (
        id_rekap INTEGER PRIMARY KEY AUTOINCREMENT,
        id_tugas INTEGER NOT NULL,
        id_anggota INTEGER NOT NULL,
        id_status INTEGER NOT NULL,
        id_riwayat INTEGER NOT NULL,
        id_unit INTEGER NOT NULL,
        keterangan_masalah TEXT,
        tanggal_selesai TEXT,
        jam_selesai TEXT,
        tanggal_gagal TEXT,
        jam_gagal TEXT
      )
    ''');
  }

  // Insert data
  static Future<int> insertDetailRiwayatLuar(Map<String, dynamic> data) async {
    final db = await InitDb.getDatabase();

    final List<Map<String, dynamic>> resultRiwayat = await db.rawQuery(
      'SELECT id_riwayat, id_unit FROM riwayat_luar ORDER BY id_riwayat DESC LIMIT 1',
    );

    if (resultRiwayat.isNotEmpty) {
      final int latestRiwayatId = resultRiwayat.first['id_riwayat'] as int;
      final int latestUnitId = resultRiwayat.first['id_unit'] as int;

      data['id_riwayat'] = latestRiwayatId;
      data['id_unit'] = latestUnitId;

      // Perbaiki format jam_selesai
      if (data.containsKey('jam_selesai') && data['jam_selesai'] is String) {
        try {
          final parsedTime = DateFormat.jm().parse(data['jam_selesai']);
          data['jam_selesai'] = DateFormat('HH:mm:ss').format(parsedTime);
        } catch (e) {
          print('Format jam_selesai error: $e');
        }
      }

      return await db.insert('detail_riwayat_luar', data);
    } else {
      throw Exception('Tidak ada data di riwayat_luar');
    }
  }

  static Future<List<Map<String, dynamic>>> getAllDetailRiwayatLuar() async {
    final db = await InitDb.getDatabase();
    return await db.rawQuery('''
    SELECT d.*, u.nama_unit, t.nama_tugas
    FROM detail_riwayat_luar d
    JOIN unit u ON d.id_unit = u.id_unit
    JOIN tugas_unit t ON d.id_unit = t.id_unit AND d.id_tugas = t.id_tugas
  ''');
  }

  // Ambil status tugas tertentu dari riwayat terakhir
  static Future<int?> getStatusFromLatestRiwayat(String idTugas) async {
    final db = await InitDb.getDatabase();

    final latestRiwayatResult = await db.rawQuery(
      'SELECT id_riwayat FROM riwayat_luar ORDER BY id_riwayat DESC LIMIT 1',
    );

    if (latestRiwayatResult.isEmpty) {
      print("🚨 [DB] Tidak ada riwayat dalam riwayat_luar");
      return 0; // default jika tidak ada riwayat
    }

    int latestRiwayatId = latestRiwayatResult.first['id_riwayat'] as int;
    print("🔍 [DB] Riwayat terbaru ID: $latestRiwayatId");

    final statusResult = await db.query(
      'detail_riwayat_luar',
      columns: ['id_status'],
      where: 'id_tugas = ? AND id_riwayat = ?',
      whereArgs: [idTugas, latestRiwayatId],
    );

    if (statusResult.isNotEmpty) {
      print(
          "✅ [DB] Status ditemukan | id_status: ${statusResult.first['id_status']}");
      return statusResult.first['id_status'] as int;
    }

    print(
        "⚠️ [DB] Tidak ditemukan status untuk idTugas: $idTugas dan idRiwayat: $latestRiwayatId");
    return 0; // default kalau tidak ada status
  }

  // Ambil detail riwayat luar berdasarkan id_tugas dari riwayat terakhir
  static Future<Map<String, dynamic>?> getRiwayatDetails(String idTugas) async {
    final db = await InitDb.getDatabase();

    final latestRiwayatResult = await db.rawQuery(
      'SELECT id_riwayat FROM riwayat_luar ORDER BY id_riwayat DESC LIMIT 1',
    );

    if (latestRiwayatResult.isEmpty) {
      print("🚨 [DB] Tidak ada riwayat dalam riwayat_luar");
      return null;
    }

    int latestRiwayatId = latestRiwayatResult.first['id_riwayat'] as int;

    final riwayatDetailsResult = await db.query(
      'detail_riwayat_luar',
      columns: [
        'tanggal_selesai',
        'jam_selesai',
        'keterangan_masalah',
        'jam_gagal',
        'tanggal_gagal'
      ],
      where: 'id_tugas = ? AND id_riwayat = ?',
      whereArgs: [idTugas, latestRiwayatId],
    );

    if (riwayatDetailsResult.isNotEmpty) {
      return {
        'tanggal_selesai': riwayatDetailsResult.first['tanggal_selesai'],
        'jam_selesai': riwayatDetailsResult.first['jam_selesai'],
        'keterangan_masalah': riwayatDetailsResult.first['keterangan_masalah'],
        'jam_gagal': riwayatDetailsResult.first['jam_gagal'],
        'tanggal_gagal': riwayatDetailsResult.first['tanggal_gagal'],
      };
    }

    print(
        "⚠️ [DB] Tidak ditemukan detail riwayat untuk idTugas: $idTugas dan idRiwayat: $latestRiwayatId");
    return null;
  }

  static Future<List<Map<String, dynamic>>> getDetailRiwayatLuarOffline(
      int idUnit, int idRiwayat) async {
    final db = await InitDb.getDatabase();
    return await db.rawQuery('''
    SELECT d.*, t.nama_tugas
    FROM detail_riwayat_luar d
    JOIN tugas_unit t 
      ON d.id_unit = t.id_unit 
     AND d.id_tugas = t.id_tugas
    WHERE d.id_unit = ? AND d.id_riwayat = ?
  ''', [idUnit, idRiwayat]);
  }

  static Future<bool> isDetailRiwayatValid() async {
    final db = await InitDb.getDatabase();

    // Ambil id_riwayat terbaru dari riwayat_luar
    final riwayatResult = await db.rawQuery('''
    SELECT id_riwayat 
    FROM riwayat_luar 
    ORDER BY id_riwayat DESC 
    LIMIT 1
  ''');

    if (riwayatResult.isEmpty) return true; // Tidak ada riwayat sama sekali

    int latestIdRiwayat = riwayatResult.first['id_riwayat'] as int;

    // Hitung jumlah detail dengan id_riwayat tersebut
    final countResult = await db.rawQuery('''
    SELECT COUNT(*) as total 
    FROM detail_riwayat_luar 
    WHERE id_riwayat = ?
  ''', [latestIdRiwayat]);

    int total = Sqflite.firstIntValue(countResult) ?? 0;

    // ✅ Return true jika jumlah = 5 atau = 0
    return total == 5 || total == 0;
  }
}
