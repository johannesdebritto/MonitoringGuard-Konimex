import 'package:flutter/material.dart';
import 'package:monitoring_guard_frontend/service/detail_riwayat_dalam_helper.dart';
import 'package:monitoring_guard_frontend/service/riwayat_dalam_helper.dart'; // Tambahkan ini
import 'package:shared_preferences/shared_preferences.dart';

class PatroliDalamLogic {
  Future<bool> submitPatroliDalam(
    BuildContext context,
    String bagian,
    String keterangan,
  ) async {
    // Cek inputan harus terisi semua
    if (bagian.trim().isEmpty || keterangan.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Bagian dan Keterangan harus diisi semua")),
      );
      return false;
    }

    // Ambil data dari shared preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? idAnggota = prefs.getString('anggota_terpilih_id');

    // Ambil id_riwayat terbaru dari tabel riwayat_dalam
    int? idRiwayat = await RiwayatDalamHelper.getLastIdRiwayatDalam();

    // Validasi data penting
    if (idAnggota == null || idRiwayat == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Anggota atau ID Riwayat belum tersedia")),
      );
      return false;
    }

    // Format waktu
    final now = DateTime.now();
    final formattedDate = now.toIso8601String().split('T')[0];
    final formattedTime =
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:00";

    // Buat data map
    final Map<String, dynamic> data = {
      "id_riwayat": idRiwayat,
      "id_anggota": idAnggota,
      "id_status": 3,
      "bagian": bagian.trim(),
      "keterangan_masalah": keterangan.trim(),
      "tanggal_selesai": formattedDate,
      "jam_selesai": formattedTime,
    };

    // Simpan ke database lokal
    try {
      await DetailRiwayatDalamHelper.insertDetailRiwayatDalam(data);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Patroli dalam berhasil disimpan lokal")),
      );
      return true;
    } catch (e) {
      print("⚠️ Exception saat simpan data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal menyimpan data secara lokal")),
      );
      return false;
    }
  }
}
