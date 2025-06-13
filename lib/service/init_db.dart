import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// Import semua helper
import 'riwayat_luar_helper.dart';
import 'riwayat_dalam_helper.dart';
import 'detail_riwayat_dalam_helper.dart';
import 'detail_riwayat_luar_helper.dart';
import 'rekap_unit_helper.dart';
import 'unit_helper.dart';
import 'tugasunit_helper.dart'; // Import tugasunit_helper.dart

class InitDb {
  static Database? _database;

  static Future<Database> getDatabase() async {
    if (_database != null) return _database!;

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'patroli_app.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await RiwayatLuarHelper.createTable(db);
        await RiwayatDalamHelper.createTable(db);
        await DetailRiwayatDalamHelper.createTable(db);
        await DetailRiwayatLuarHelper.createTable(db);
        await RekapUnitHelper.createTable(db);
        await UnitHelper.createTable(db);
        await TugasUnitHelper.createTable(db); // Tambahkan ini
      },
    );

    return _database!;
  }

  static Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
