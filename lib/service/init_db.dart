import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// Import semua helper
import 'riwayat_luar_helper.dart';
import 'riwayat_dalam_helper.dart';
import 'detail_riwayat_dalam_helper.dart';
import 'detail_riwayat_luar_helper.dart';
import 'tugas_unit_helper.dart';

class InitDb {
  static Database? _database;

  static Future<Database> getDatabase() async {
    if (_database != null) return _database!;

    // Path database
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'patroli_app.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Panggil createTable dari semua helper di sini
        await RiwayatLuarHelper.createTable(db);
        await RiwayatDalamHelper.createTable(db);
        await DetailRiwayatDalamHelper.createTable(db);
        await DetailRiwayatLuarHelper.createTable(db);
        await TugasUnitHelper.createTable(db);
      },
    );

    return _database!;
  }

  // Fungsi untuk menutup database jika diperlukan
  static Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
