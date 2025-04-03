import 'dart:ui';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class CustomModalLogic {
  final String idTugas;
  String idRiwayat = ""; // Ambil dari SharedPreferences nanti

  String status = "Belum Selesai";
  String tanggalSelesai = '--';
  String jamSelesai = '--';
  String tanggalGagal = '--';
  String jamGagal = '--';
  List<String> masalahList = [];

  CustomModalLogic({required this.idTugas, required String idRiwayat});

  Future<void> fetchRekapData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      idRiwayat = prefs.getString('id_riwayat') ?? "";

      if (idRiwayat.isEmpty) {
        print("🚨 ID Riwayat tidak ditemukan di SharedPreferences!");
        return;
      }

      final url = Uri.parse(
          '${dotenv.env['BASE_URL']}/api/tugas/rekap/$idTugas/$idRiwayat');
      print("🔍 Fetching: $url");

      final response = await http.get(url);
      print("📡 Response dari API: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("✅ Data dari API: $data");

        if (data.isEmpty) {
          print("ℹ️ Tidak ada tugas yang ditemukan.");
          return;
        }

        if (data['id_status'].toString() == '2') {
          status = "Selesai";
          tanggalSelesai = _formatTanggal(data['tanggal_selesai']);
          jamSelesai = _formatJam(data['jam_selesai']);
        } else if (data['keterangan_masalah'] != null &&
            data['keterangan_masalah'].isNotEmpty) {
          status = "Ada Masalah";
          tanggalGagal = _formatTanggal(data['tanggal_gagal']);
          jamGagal = _formatJam(data['jam_gagal']);
          masalahList = [data['keterangan_masalah']];
        } else {
          status = "Belum Selesai";
        }
      } else {
        print(
            "ℹ️ Tidak ada tugas yang ditemukan (status: ${response.statusCode}).");
      }
    } catch (e) {
      print("❌ ERROR fetching rekap data: $e");
    }
  }

  String _formatTanggal(String? date) {
    if (date == null || date.isEmpty || date == 'null') return '--';
    try {
      DateTime parsedDate = DateTime.parse(date).toLocal();
      return DateFormat('dd-MM-yyyy').format(parsedDate);
    } catch (e) {
      print("Error parsing tanggal: $e");
      return '--';
    }
  }

  String _formatJam(String? time) {
    if (time == null || time.isEmpty || time == 'null') return '--';
    try {
      return time.length == 5 ? "$time WIB" : "${time.substring(0, 5)} WIB";
    } catch (e) {
      print("Error parsing jam: $e");
      return '--';
    }
  }

  Color getStatusColor() {
    switch (status) {
      case "Selesai":
        return const Color(0xFF38B000);
      case "Belum Selesai":
        return const Color(0xFFFCA311);
      case "Ada Masalah":
        return const Color(0xFFD00000);
      default:
        return const Color(0xFF6C757D); // Warna default abu-abu
    }
  }
}
