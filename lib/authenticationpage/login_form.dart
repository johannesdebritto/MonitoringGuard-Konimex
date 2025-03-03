import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monitoring_guard_frontend/authenticationpage/login_modal.dart';
import 'package:monitoring_guard_frontend/main.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  String _email = "";
  String _password = "";
  String _pegawai = "";

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2C3E50).withOpacity(0.95),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Text(
              "LOGIN",
              style: GoogleFonts.robotoSlab(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
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
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const MainNavigation()),
                );
              },
              child: Text(
                "MASUK",
                style: GoogleFonts.robotoSlab(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.robotoSlab(
        fontSize: 16,
        color: Colors.white,
      ),
    );
  }

  Widget _buildTextField(String value, String label, String fieldType) {
    return GestureDetector(
      onTap: () async {
        final result = await showDialog<String>(
          context: context,
          barrierDismissible: true,
          builder: (context) => LoginModalScreen(
            initialValue: value,
            fieldType: fieldType,
          ),
        );
        if (result != null) {
          setState(() {
            if (fieldType == "email") _email = result;
            if (fieldType == "password") _password = result;
            if (fieldType == "pegawai") _pegawai = result;
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
            fontSize: 16,
            color: value.isEmpty ? Colors.grey : Colors.black,
          ),
        ),
      ),
    );
  }
}
