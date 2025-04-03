import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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

      print("🔄 Fetch riwayat dengan ID: $idRiwayat...");

      final url = Uri.parse(
          '${dotenv.env['BASE_URL']}/api/tugas_dalam/patroli-dalam/$idRiwayat');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse is Map<String, dynamic> &&
            jsonResponse.containsKey('data')) {
          print("✅ Data berhasil di-fetch: ${jsonResponse['data']}");
          return List<dynamic>.from(jsonResponse['data']);
        } else {
          print("❌ Format data tidak sesuai");
          return [];
        }
      } else {
        print(
            "❌ Gagal fetch riwayat, status code: ${response.statusCode}, response: ${response.body}");
        return [];
      }
    } catch (e) {
      print("❌ Error saat fetch riwayat: $e");
      return [];
    }
  }
}
