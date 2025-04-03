import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TugasService {
  static Future<void> submitData({
    required BuildContext context,
    required VoidCallback onSubmitSuccess,
  }) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? idRiwayat = prefs.getString('id_riwayat');

      if (idRiwayat == null || idRiwayat.isEmpty) {
        _showMessage(context, "🚨 ID Riwayat tidak ditemukan!", Colors.red);
        return;
      }

      String? baseUrl = dotenv.env['BASE_URL'];
      if (baseUrl == null || baseUrl.isEmpty) {
        _showMessage(
            context, "🚨 BASE_URL tidak ditemukan di .env!", Colors.red);
        return;
      }

      final url = Uri.parse('$baseUrl/api/tugas_dalam/update-status-dalam');

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({"id_riwayat": idRiwayat}),
      );

      if (response.statusCode != 200) {
        _showMessage(
          context,
          "❌ Gagal submit tugas! Status: ${response.statusCode}",
          Colors.red,
        );
        return;
      }

      final Map<String, dynamic> jsonResponse = json.decode(response.body);

      if (jsonResponse['success'] == true) {
        await prefs.setBool(
            'is_submitted_dalam', true); // ✅ Menyimpan status submit
        _showMessage(context, "✅ Tugas berhasil disubmit!", Colors.green);

        if (context.mounted) {
          // Tutup modal dan jalankan callback setelahnya
          Navigator.pop(context, true);
          Future.delayed(const Duration(milliseconds: 300), () {
            if (context.mounted) onSubmitSuccess();
          });
        }
      } else {
        _showMessage(
          context,
          "❌ ${jsonResponse['message'] ?? 'Gagal submit tugas!'}",
          Colors.red,
        );
      }
    } catch (e) {
      _showMessage(context, "🚨 Terjadi kesalahan: $e", Colors.red);
    }
  }

  static void _showMessage(BuildContext context, String message, Color color) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
