import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class KontenRiwayatLogic {
  final Map<String, dynamic> item;
  final Function() updateState;
  List<dynamic> detailRiwayat = [];
  bool isLoading = true;

  KontenRiwayatLogic(this.item, this.updateState);

  void init() {
    print("🟠 [DEBUG] widget.item sebelum fetch: $item");

    final int? idUnit = int.tryParse(item['id_unit'].toString());
    final int? idRiwayat = int.tryParse(item['id_riwayat'].toString());

    if (idUnit == null || idRiwayat == null) {
      print(
          "❌ [ERROR] id_unit atau id_riwayat NULL atau bukan angka! Tidak bisa fetch data.");
      isLoading = false;
      updateState();
      return;
    }

    print("🟡 [DEBUG] id_unit yang diambil dari widget.item: $idUnit");
    print("🟡 [DEBUG] id_riwayat yang diambil dari widget.item: $idRiwayat");
    fetchDetailRiwayat(idUnit, idRiwayat);
  }

  Future<void> fetchDetailRiwayat(int idUnit, int idRiwayat) async {
    try {
      print(
          "🔵 [DEBUG] Mengambil data dari API untuk id_unit: $idUnit dan id_riwayat: $idRiwayat");

      final url = Uri.parse(
          '${dotenv.env['BASE_URL']}/api/tugas/detail_riwayat/$idUnit/$idRiwayat');
      print("🌐 [DEBUG] Request ke API: $url");

      final response = await http.get(url);
      print("🟣 [DEBUG] Status Code Response: ${response.statusCode}");

      if (response.statusCode == 200) {
        final body = utf8.decode(response.bodyBytes);
        final decoded = jsonDecode(body);

        if (decoded is List<dynamic>) {
          detailRiwayat = decoded;
          print("✅ [SUCCESS] Data detail_riwayat diterima: $decoded");
        } else {
          print("⚠️ [WARNING] Response tidak berbentuk List! Cek format JSON.");
          detailRiwayat = [];
        }
      } else if (response.statusCode == 404) {
        print("📭 [INFO] Tidak ada riwayat, menampilkan pesan.");
        detailRiwayat = [];
      } else {
        print(
            "❌ [ERROR] Gagal mengambil data. Status code: ${response.statusCode}");
        print("❗ [DEBUG] Response body: ${response.body}");
        detailRiwayat = [];
      }
    } catch (e) {
      print("🔥 [EXCEPTION] Error saat mengambil data: $e");
      detailRiwayat = [];
    } finally {
      isLoading = false;
      updateState();
    }
  }
}
