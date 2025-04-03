import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TugasScreenLogic {
  Future<String> loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('anggota_terpilih') ??
        prefs.getString('anggota1') ??
        "Anggota Tidak Diketahui";
  }

  Future<List> fetchTugas() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? idUnit = prefs.getString('id_unit');
    if (idUnit == null) return [];

    final response = await http
        .get(Uri.parse('${dotenv.env['BASE_URL']}/api/tugas/$idUnit'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Gagal mengambil data tugas");
    }
  }

  Future<Map<String, dynamic>?> fetchRekap(String idTugas) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? idRiwayat = prefs.getString('id_riwayat');

    if (idRiwayat == null || idRiwayat.isEmpty) {
      print("🚨 ID Riwayat tidak ditemukan di SharedPreferences!");
      return null;
    }

    final url = Uri.parse(
        '${dotenv.env['BASE_URL']}/api/tugas/rekap/$idTugas/$idRiwayat');
    print("🔍 Fetching: $url");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      print("✅ Data ditemukan!");
      return json.decode(response.body);
    } else if (response.statusCode == 404) {
      print("⚠️ Tugas belum dimulai, data masih kosong.");
      return {}; // Balikin map kosong biar tetap bisa dihandle di UI
    } else {
      print("❌ Gagal fetch rekap: ${response.statusCode} - ${response.body}");
      return null;
    }
  }

  Future<int?> cekStatusTugas(String idTugas) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? idRiwayat = prefs.getString('id_riwayat');

    if (idRiwayat == null || idRiwayat.isEmpty) {
      print("🚨 ID Riwayat tidak ditemukan di SharedPreferences!");
      return null;
    }

    final response = await http.get(
      Uri.parse(
          '${dotenv.env['BASE_URL']}/api/tugas/cek-status/$idTugas/$idRiwayat'),
    );

    print("🔍 Cek status tugas: ${response.request?.url}");

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['id_status']; // Sesuai dengan respons dari backend
    } else if (response.statusCode == 404) {
      print("⚠️ Tidak ada tugas ditemukan, dianggap kosong.");
      return 0; // Status "Belum Ada Tugas"
    } else {
      print(
          "❌ Gagal mengecek status tugas: ${response.statusCode} - ${response.body}");
      return null;
    }
  }
}
