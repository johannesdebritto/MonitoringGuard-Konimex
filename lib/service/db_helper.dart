import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _database;

  static Future<Database> initDb() async {
    if (_database != null) return _database!;
    String path = join(await getDatabasesPath(), 'app_local.db');

    _database = await openDatabase(
      path,
      version: 2, // Naikkan versi database

      onCreate: (db, version) async {
        // Tabel riwayat_luar
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

        // Tabel riwayat_dalam
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

        // Tabel detail_riwayat_luar
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

        // Tabel detail_riwayat_dalam
        await db.execute(''' 
          CREATE TABLE IF NOT EXISTS detail_riwayat_dalam (
            id_rekap INTEGER PRIMARY KEY AUTOINCREMENT,
            nama_anggota TEXT NOT NULL,
            id_status INTEGER NOT NULL,
            bagian TEXT,
            keterangan_masalah TEXT,
            tanggal_selesai TEXT,
            jam_selesai TEXT,
            id_riwayat INTEGER NOT NULL
          )
        ''');

        // Tabel tugas_unit
        await db.execute('''
  CREATE TABLE tugas_unit (
    id_tugas INTEGER PRIMARY KEY AUTOINCREMENT,
    id_unit INTEGER NOT NULL,
    nama_tugas TEXT NOT NULL,
    id_status INTEGER DEFAULT 1
  )
''');
      },

      // onUpgrade digunakan untuk memperbarui struktur tabel saat versi database berubah
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Membuat tabel baru tanpa kolom id_anggota
          await db.execute(''' 
            CREATE TABLE detail_riwayat_dalam_new (
              id_rekap INTEGER PRIMARY KEY AUTOINCREMENT,
              nama_anggota TEXT NOT NULL,
              id_status INTEGER NOT NULL,
              bagian TEXT,
              keterangan_masalah TEXT,
              tanggal_selesai TEXT,
              jam_selesai TEXT,
              id_riwayat INTEGER NOT NULL
            );
          ''');

          // Salin data dari tabel lama ke tabel baru
          await db.execute(''' 
            INSERT INTO detail_riwayat_dalam_new (id_rekap, nama_anggota, id_status, bagian, keterangan_masalah, tanggal_selesai, jam_selesai, id_riwayat)
            SELECT id_rekap, nama_anggota, id_status, bagian, keterangan_masalah, tanggal_selesai, jam_selesai, id_riwayat
            FROM detail_riwayat_dalam;
          ''');

          // Hapus tabel lama
          await db.execute('DROP TABLE detail_riwayat_dalam');

          // Ganti nama tabel baru menjadi tabel lama
          await db.execute(
              'ALTER TABLE detail_riwayat_dalam_new RENAME TO detail_riwayat_dalam');
        }
      },
    );

    return _database!;
  }

  // === RIWAYAT LUAR ===
  static Future<int> insertRiwayatLuar(Map<String, dynamic> data) async {
    final db = await initDb();
    return await db.insert('riwayat_luar', data);
  }

  static Future<List<Map<String, dynamic>>> getAllRiwayatLuar() async {
    final db = await initDb();
    return await db.query('riwayat_luar');
  }

  // === RIWAYAT DALAM ===
  static Future<int> insertRiwayatDalam(Map<String, dynamic> data) async {
    final db = await initDb();
    return await db.insert('riwayat_dalam', data);
  }

  static Future<List<Map<String, dynamic>>> getAllRiwayatDalam() async {
    final db = await initDb();
    return await db.query('riwayat_dalam');
  }

  static Future<Map<String, dynamic>> getRiwayatDalamById(int idRiwayat) async {
    final db = await initDb();
    final result = await db.query(
      'riwayat_dalam',
      where: 'id_riwayat = ?',
      whereArgs: [idRiwayat],
    );
    return result.isNotEmpty
        ? result.first
        : {}; // Mengembalikan data pertama atau map kosong jika tidak ditemukan
  }

// == Detail Riwayat Luar == //
  static Future<int> insertDetailRiwayatLuar(Map<String, dynamic> data) async {
    final db = await initDb();
    return await db.insert('detail_riwayat_luar', data);
  }

  static Future<List<Map<String, dynamic>>> getAllDetailRiwayatLuar() async {
    final db = await initDb();
    return await db.query('detail_riwayat_luar');
  }

  static Future<int> getIdUnit() async {
    final db = await initDb();
    final result =
        await db.query('riwayat_luar', columns: ['id_unit'], limit: 1);
    return result.isNotEmpty ? (result.first['id_unit'] as int) : 0;
  }

// Ambil data dari detail_riwayat_luar berdasarkan id_tugas dan id_riwayat
  static Future<Map<String, dynamic>?> getDetailRiwayatLuarByIdTugas(
      String idTugas, String idRiwayat) async {
    final db = await initDb();
    final result = await db.query(
      'detail_riwayat_luar',
      where: 'id_tugas = ? AND id_riwayat = ?',
      whereArgs: [idTugas, idRiwayat],
    );
    return result.isNotEmpty ? result.first : null;
  }

  // == Detail Riwayat Dalam == //
  static Future<int> insertDetailRiwayatDalam(Map<String, dynamic> data) async {
    final db = await initDb();
    return await db.insert('detail_riwayat_dalam', data);
  }

  static Future<List<Map<String, dynamic>>> getAllDetailRiwayatDalam() async {
    final db = await initDb();
    return await db.query('detail_riwayat_dalam');
  }

  // == Detail Riwayat Dalam by ID == //
  static Future<List<Map<String, dynamic>>> getDetailRiwayatDalamById(
      int idRiwayat) async {
    final db = await initDb();
    return await db.query(
      'detail_riwayat_dalam',
      where: 'id_riwayat = ?',
      whereArgs: [idRiwayat],
    );
  }

  // Update data riwayat_dalam berdasarkan id_riwayat
  static Future<int> updateRiwayatDalam(
      int idRiwayat, Map<String, dynamic> data) async {
    final db = await initDb();
    return await db.update(
      'riwayat_dalam',
      data,
      where: 'id_riwayat = ?',
      whereArgs: [idRiwayat],
    );
  }

  // === TUGAS UNIT ===
  static Future<int> insertTugasUnit(Map<String, dynamic> data) async {
    final db = await initDb();
    return await db.insert('tugas_unit', data);
  }

  static Future<List<Map<String, dynamic>>> getAllTugasUnit() async {
    final db = await initDb();
    return await db.query('tugas_unit');
  }
}
