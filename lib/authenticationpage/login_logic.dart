import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:monitoring_guard_frontend/authenticationpage/warning_modal.dart';
import 'package:monitoring_guard_frontend/tugas_selection/home_selection.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginLogic {
  Future<bool> login({
    required BuildContext context,
    required String email,
    required String password,
    required String anggota1,
    String? anggota2,
    required String patroli,
    required String unitKerja,
  }) async {
    print("✅ LOGIN FUNCTION DIPANGGIL");

    if (email.isEmpty ||
        password.isEmpty ||
        anggota1.isEmpty ||
        patroli.isEmpty ||
        unitKerja.isEmpty) {
      print("⚠️ Form kosong, menampilkan warning dialog");
      if (!context.mounted) return false;
      showDialog(
        context: context,
        builder: (context) => WarningModalScreen(
          errors: [
            "Email, password, anggota1, patroli, dan unit kerja harus diisi"
          ],
          color: Colors.orange,
        ),
      );
      return false;
    }

    try {
      var url = Uri.parse('${dotenv.env['BASE_URL']}/api/auth/login');
      var response = await http
          .post(
            url,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "email": email,
              "password": password,
              "anggota1": anggota1,
              "anggota2": anggota2?.isNotEmpty == true ? anggota2 : null,
              "patroli": patroli,
              "unit_kerja": unitKerja,
            }),
          )
          .timeout(const Duration(seconds: 10)); // Tambah timeout 10 detik

      print("📩 Response status: ${response.statusCode}");

      if (response.statusCode == 200) {
        var data;
        try {
          data = jsonDecode(response.body);
          if (data is! Map) throw Exception("Invalid JSON format");
        } catch (e) {
          print("🚨 ERROR: Respons dari server bukan JSON valid -> $e");
          return false;
        }

        print("🔍 Data dari API sebelum disimpan: $data");

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('id_unit', (data['id_unit'] ?? "").toString());
        await prefs.setString('nama_unit', data['nama_unit'] ?? "");
        await prefs.setString(
            'id_unit_kerja', (data['id_unit_kerja'] ?? "").toString());
        await prefs.setString(
            'id_riwayat', (data['id_riwayat'] ?? "").toString());
        await prefs.setString('anggota1', data['anggota1'] ?? "");
        await prefs.setString('anggota2', data['anggota2'] ?? "");
        await prefs.setString(
            'id_patroli', (data['id_patroli'] ?? "").toString());

        print("✅ Data berhasil disimpan ke SharedPreferences");

        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => const HomeSelectionScreen()),
          );
        }
        return true;
      } else {
        var errorMessage = "Gagal login, coba lagi nanti";
        try {
          var errorData = jsonDecode(response.body);
          if (errorData is Map && errorData.containsKey('message')) {
            errorMessage = errorData['message'];
          }
        } catch (_) {}

        print("🚨 ERROR: $errorMessage");
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (context) => WarningModalScreen(
              errors: [errorMessage],
              color: Colors.red,
            ),
          );
        }
        return false;
      }
    } catch (e) {
      print("🚨 ERROR (Exception): $e");
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => WarningModalScreen(
            errors: ["Terjadi kesalahan, periksa koneksi internet"],
            color: Colors.red,
          ),
        );
      }
      return false;
    }
  }
}
