import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:monitoring_guard_frontend/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'warning_modal.dart'; // Pastikan import sesuai struktur proyek

class LoginLogic {
  Future<bool> login({
    required BuildContext context,
    required String email,
    required String password,
    required String anggota1,
    String? anggota2, // Anggota2 bisa kosong
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
          errors: ["Semua kolom harus diisi"],
          color: Colors.orange,
        ),
      );
      return false;
    }

    try {
      final String apiUrl = '${dotenv.env['BASE_URL']}/api/auth/login';
      print("🔄 Mengirim request ke backend: $apiUrl");

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password,
          "anggota1": anggota1,
          "anggota2": anggota2?.isNotEmpty == true ? anggota2 : null,
          "patroli": patroli,
          "unit_kerja": unitKerja,
        }),
      );

      print("🔍 Response diterima. Status code: ${response.statusCode}");
      print("📝 Response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['id_unit'] == null || data['id_riwayat'] == null) {
          print("❌ LOGIN GAGAL: Data yang diterima tidak lengkap!");
          if (!context.mounted) return false;
          showDialog(
            context: context,
            builder: (context) => WarningModalScreen(
              errors: ["Data yang diterima dari server tidak valid."],
              color: Colors.redAccent,
            ),
          );
          return false;
        }

        SharedPreferences prefs = await SharedPreferences.getInstance();
        try {
          await prefs.setString('id_unit', data['id_unit'].toString());
          await prefs.setString(
              'nama_unit', data['nama_unit'] ?? "Tidak Diketahui");
          await prefs.setString(
              'anggota1', data['anggota1'] ?? "Tidak Diketahui");
          await prefs.setString(
              'anggota2', data['anggota2'] ?? ""); // Bisa kosong
          await prefs.setString('id_patroli', data['id_patroli'].toString());
          await prefs.setString(
              'id_unit_kerja', data['id_unit_kerja'].toString());
          await prefs.setString('id_riwayat', data['id_riwayat'].toString());
          print("✅ Data berhasil disimpan ke SharedPreferences");
        } catch (e) {
          print("🚨 ERROR MENYIMPAN DATA KE SHAREDPREFERENCES: $e");
          return false;
        }

        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainNavigation()),
          );
        }

        return true; // ✅ Return true jika login berhasil
      } else {
        final errorMessage =
            jsonDecode(response.body)['message'] ?? "Login gagal";
        print("❌ LOGIN GAGAL: $errorMessage");
        if (!context.mounted) return false;
        showDialog(
          context: context,
          builder: (context) => WarningModalScreen(
            errors: [errorMessage],
            color: Colors.redAccent,
          ),
        );
        return false;
      }
    } catch (e) {
      print("🚨 ERROR SAAT LOGIN: $e");
      if (!context.mounted) return false;
      showDialog(
        context: context,
        builder: (context) => WarningModalScreen(
          errors: ["Terjadi kesalahan, coba lagi"],
          color: Colors.redAccent,
        ),
      );
      return false;
    }
  }
}
