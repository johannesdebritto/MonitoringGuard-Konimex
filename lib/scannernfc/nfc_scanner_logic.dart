import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:monitoring_guard_frontend/widgets/modal_nfc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class NFCScannerLogic {
  // Ambil data tugas dari backend berdasarkan id_unit
  static Future<List<dynamic>> fetchTugas() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? idUnit = prefs.getString('id_unit');

      if (idUnit == null) {
        print("ID Unit tidak ditemukan");
        return [];
      }

      final response = await http.get(
        Uri.parse('${dotenv.env['BASE_URL']}/api/tugas/$idUnit'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print("Gagal mengambil data tugas");
        return [];
      }
    } catch (e) {
      print("Error: $e");
      return [];
    }
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
