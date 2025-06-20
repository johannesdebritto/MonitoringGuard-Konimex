import 'package:sqflite/sqflite.dart';
import 'init_db.dart';

class SyncHelper {
  Future<Database> _getDatabase() async {
    return await InitDb.getDatabase();
  }

  Future<List<Map<String, dynamic>>> getDataForSync() async {
    final db = await _getDatabase();

    // Ambil max id_riwayat di masing-masing tabel
    final maxLuarResult =
        await db.rawQuery('SELECT MAX(id_riwayat) as max_id FROM riwayat_luar');
    final maxDalamResult = await db
        .rawQuery('SELECT MAX(id_riwayat) as max_id FROM riwayat_dalam');

    final maxLuar = maxLuarResult.first['max_id'] as int?;
    final maxDalam = maxDalamResult.first['max_id'] as int?;

    List<Map<String, dynamic>> result = [];

    // Ambil data riwayat_luar dan detailnya berdasarkan maxLuar jika ada
    if (maxLuar != null) {
      final riwayatLuar = await db
          .query('riwayat_luar', where: 'id_riwayat = ?', whereArgs: [maxLuar]);
      final detailLuar = await db.query('detail_riwayat_luar',
          where: 'id_riwayat = ?', whereArgs: [maxLuar]);

      print("📦 Riwayat Luar: $riwayatLuar");
      print("🧾 Detail Riwayat Luar: $detailLuar");

      for (var item in riwayatLuar) {
        result.add({"type": "riwayat_luar", "data": item});
      }
      for (var item in detailLuar) {
        result.add({"type": "detail_riwayat_luar", "data": item});
      }
    }

    // Ambil data riwayat_dalam dan detailnya berdasarkan maxDalam jika ada
    if (maxDalam != null) {
      final riwayatDalam = await db.query('riwayat_dalam',
          where: 'id_riwayat = ?', whereArgs: [maxDalam]);
      final detailDalam = await db.query('detail_riwayat_dalam',
          where: 'id_riwayat = ?', whereArgs: [maxDalam]);

      print("🏠 Riwayat Dalam: $riwayatDalam");
      print("📋 Detail Riwayat Dalam: $detailDalam");

      for (var item in riwayatDalam) {
        result.add({"type": "riwayat_dalam", "data": item});
      }
      for (var item in detailDalam) {
        result.add({"type": "detail_riwayat_dalam", "data": item});
      }
    }

    return result;
  }
}
