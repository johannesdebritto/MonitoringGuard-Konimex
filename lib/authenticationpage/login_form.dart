import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:monitoring_guard_frontend/authenticationpage/login_modal.dart';
import 'package:monitoring_guard_frontend/authenticationpage/warning_modal.dart';
import 'package:monitoring_guard_frontend/main.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  String _email = "", _password = "", _pegawai = "";

  Future<void> login() async {
    print("✅ LOGIN FUNCTION DIPANGGIL"); // Debugging awal

    if (_email.isEmpty || _password.isEmpty || _pegawai.isEmpty) {
      print("⚠️ Form kosong, menampilkan warning dialog");
      if (!mounted) return; // Cek mounted sebelum showDialog
      showDialog(
        context: context,
        builder: (context) => WarningModalScreen(
          errors: ["Semua kolom harus diisi"],
          color: Colors.yellow,
        ),
      );
      return;
    }

    try {
      final String apiUrl = '${dotenv.env['BASE_URL']}/api/auth/login';
      print("🔄 Mengirim request ke backend: $apiUrl");

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(
          {"email": _email, "password": _password, "nama_anggota": _pegawai},
        ),
      );

      print("🔍 Response diterima. Status code: ${response.statusCode}");
      print("📝 Response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['id_unit'] == null || data['id_riwayat'] == null) {
          print("❌ LOGIN GAGAL: Data yang diterima tidak lengkap!");
          if (!mounted) return;
          showDialog(
            context: context,
            builder: (context) => WarningModalScreen(
              errors: ["Data yang diterima dari server tidak valid."],
              color: Colors.redAccent,
            ),
          );
          return;
        }

        SharedPreferences prefs = await SharedPreferences.getInstance();
        try {
          await prefs.setString('id_unit', data['id_unit'].toString());
          await prefs.setString(
              'nama_unit', data['nama_unit'] ?? "Tidak Diketahui");
          await prefs.setString(
              'nama_anggota', data['nama_anggota'] ?? "Tidak Diketahui");
          await prefs.setString('id_riwayat', data['id_riwayat'].toString());
          print("✅ Data berhasil disimpan ke SharedPreferences");
        } catch (e) {
          print("🚨 ERROR MENYIMPAN DATA KE SHAREDPREFERENCES: $e");
        }

        print("✅ LOGIN BERHASIL, PINDAH KE HALAMAN UTAMA");
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainNavigation()),
          );
        }
      } else {
        final errorMessage =
            jsonDecode(response.body)['message'] ?? "Login gagal";
        print("❌ LOGIN GAGAL: $errorMessage");
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (context) => WarningModalScreen(
            errors: [errorMessage],
            color: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      print("🚨 ERROR SAAT LOGIN: $e");
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => WarningModalScreen(
          errors: ["Terjadi kesalahan, coba lagi"],
          color: Colors.redAccent,
        ),
      );
    }
  }

  Widget _buildLabel(String text) => Text(
        text,
        style: GoogleFonts.robotoSlab(fontSize: 16, color: Colors.white),
      );

  Widget _buildTextField(String value, String label, String fieldType) {
    return GestureDetector(
      onTap: () async {
        final result = await showDialog<String>(
          context: context,
          barrierDismissible: true,
          builder: (context) =>
              LoginModalScreen(initialValue: value, fieldType: fieldType),
        );
        if (result != null) {
          setState(() {
            if (fieldType == "email") {
              _email = result;
            } else if (fieldType == "password") {
              _password = result;
            } else {
              _pegawai = result;
            }
          });
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black, width: 2),
        ),
        child: Text(
          value.isEmpty
              ? label
              : (fieldType == "password" ? "*" * value.length : value),
          style: GoogleFonts.robotoSlab(
              fontSize: 16, color: value.isEmpty ? Colors.grey : Colors.black),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: const Color(0xFF2C3E50).withOpacity(0.95),
          borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Text("LOGIN",
                style: GoogleFonts.robotoSlab(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
          ),
          const SizedBox(height: 20),
          _buildLabel("Email Gedung"),
          _buildTextField(_email, "Masukkan Email Gedung", "email"),
          const SizedBox(height: 15),
          _buildLabel("Password"),
          _buildTextField(_password, "Masukkan Password", "password"),
          const SizedBox(height: 15),
          _buildLabel("Nama Pegawai"),
          _buildTextField(_pegawai, "Masukkan Nama Pegawai", "pegawai"),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF38B000),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
              onPressed: () {
                print("Tombol LOGIN ditekan!");
                login();
              },
              child: Text("MASUK",
                  style: GoogleFonts.robotoSlab(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
