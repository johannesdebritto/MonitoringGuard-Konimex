import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:monitoring_guard_frontend/widgets/modal_nfc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class NFCScannerLogic {
  static List<Map<String, dynamic>> nfcTasks = []; // Menyimpan data NFC di sini

  // Ambil data tugas dari backend berdasarkan id_unit
  static Future<void> fetchTugas() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? idUnit = prefs.getString('id_unit');

      if (idUnit == null) {
        print("ID Unit tidak ditemukan");
        return;
      }

      final response = await http.get(
        Uri.parse('${dotenv.env['BASE_URL']}/api/tugas/$idUnit'),
      );

      if (response.statusCode == 200) {
        List<dynamic> tugasList = jsonDecode(response.body);

        // Simpan tugas yang diterima ke SharedPreferences
        await prefs.setString('tugas_data', jsonEncode(tugasList));
        print("Data tugas berhasil disimpan di SharedPreferences.");

        // Simpan data NFC ke dalam variabel statis nfcTasks
        nfcTasks = List<Map<String, dynamic>>.from(tugasList);
      } else {
        print("Gagal mengambil data tugas untuk scan");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  // Ambil data tugas yang sudah disimpan di SharedPreferences
  static Future<List<dynamic>> getTugasFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? tugasData = prefs.getString('tugas_data');

    if (tugasData != null) {
      return jsonDecode(tugasData);
    }

    return []; // Kalau data tidak ada
  }

  // Fungsi untuk menampilkan modal NFC
  static void showNFCModal({
    required BuildContext context,
    required Map<String, dynamic> tugas,
    required String status,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return NFCModalScreen(
          status: status, // "aman" atau "masalah"
          idTugas: tugas['id_tugas'].toString(),
          onConfirm: onConfirm, // Refresh daftar tugas setelah update
        );
      },
    );
  }
}
