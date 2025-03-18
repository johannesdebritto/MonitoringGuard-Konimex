import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monitoring_guard_frontend/authenticationpage/login_modal_email.dart';

class EmailPasswordForm extends StatefulWidget {
  final String email;
  final String password;
  final Function(String, String) onChanged;

  const EmailPasswordForm({
    super.key,
    required this.email,
    required this.password,
    required this.onChanged,
  });

  @override
  State<EmailPasswordForm> createState() => _EmailPasswordFormState();
}

class _EmailPasswordFormState extends State<EmailPasswordForm> {
  Widget _buildLabel(String text) => Text(
        text,
        style: GoogleFonts.inter(
            fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
      );

  Widget _buildTextField(
      BuildContext context, String value, String label, String fieldType) {
    return GestureDetector(
      onTap: () async {
        final result = await showDialog<String>(
          context: context,
          barrierDismissible: true,
          builder: (context) =>
              LoginModalScreen(initialValue: value, fieldType: fieldType),
        );
        if (result != null) {
          widget.onChanged(
            fieldType == "email" ? result : widget.email,
            fieldType == "password" ? result : widget.password,
          );
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
            vertical: 18, horizontal: 15), // Padding lebih luas
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12), // Sudut lebih bulat
          border: Border.all(color: Colors.black, width: 2),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value.isEmpty
                    ? label
                    : (fieldType == "password" ? "*" * value.length : value),
                style: GoogleFonts.inter(
                  fontSize: 16, // Font lebih besar
                  color: value.isEmpty ? Colors.grey : Colors.black,
                ),
                overflow: TextOverflow.ellipsis, // Potong teks panjang
                maxLines: 1, // Tetap satu baris
                softWrap: false, // Jangan turun ke bawah
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel("Email Gedung"),
        const SizedBox(height: 5),
        _buildTextField(
            context, widget.email, "Masukkan Email Gedung", "email"),
        const SizedBox(height: 20),
        _buildLabel("Password"),
        const SizedBox(height: 5),
        _buildTextField(
            context, widget.password, "Masukkan Password", "password"),
      ],
    );
  }
}
