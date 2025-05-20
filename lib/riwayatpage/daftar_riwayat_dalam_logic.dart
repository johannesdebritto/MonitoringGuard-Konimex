import 'package:monitoring_guard_frontend/service/detail_riwayat_dalam_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DetailRiwayatDalamService {
  Future<bool> checkSubmissionStatus() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getBool('is_submitted_dalam') ?? false;
    } catch (e) {
      print("❌ Error saat mengecek status submit: $e");
      return false;
    }
  }

  Future<List<dynamic>> fetchDetailRiwayatDalam() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? idRiwayat = prefs.getString('id_riwayat');

      if (idRiwayat == null || idRiwayat.isEmpty) {
        print("🚨 ID Riwayat kosong, fetch dibatalkan.");
        return [];
      }

      print(
          "🔄 Mengambil data riwayat dalam dari penyimpanan lokal dengan ID: $idRiwayat...");

      // Mengambil data dari database lokal (SQLite)
      final riwayatDetail =
          await DetailRiwayatDalamHelper.getDetailRiwayatDalamById(
              int.parse(idRiwayat));

      if (riwayatDetail.isEmpty) {
        print("❌ Data riwayat tidak ditemukan di penyimpanan lokal.");
        return [];
      }

      print("✅ Data riwayat berhasil diambil dari penyimpanan lokal.");

      // ⛔ Filter: Hapus data yang kosong
      return riwayatDetail
          .where((item) =>
              (item['bagian']?.toString().trim().isNotEmpty ?? false) ||
              (item['keterangan_masalah']?.toString().trim().isNotEmpty ??
                  false))
          .map((item) {
        return {
          'id_rekap': item['id_rekap'],
          'nama_anggota': item['nama_anggota'],
          'id_status': item['id_status'],
          'bagian': item['bagian'],
          'keterangan_masalah': item['keterangan_masalah'],
          'tanggal_selesai': item['tanggal_selesai'],
          'jam_selesai': item['jam_selesai'],
          'id_riwayat': item['id_riwayat'],
        };
      }).toList();
    } catch (e) {
      print("❌ Error saat mengambil data riwayat dalam: $e");
      return [];
    }
  }
}
