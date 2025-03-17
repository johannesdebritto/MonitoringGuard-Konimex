import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monitoring_guard_frontend/authenticationpage/login_modal.dart';

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
        style: GoogleFonts.robotoSlab(fontSize: 16, color: Colors.white),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel("Email Gedung"),
        _buildTextField(
            context, widget.email, "Masukkan Email Gedung", "email"),
        const SizedBox(height: 15),
        _buildLabel("Password"),
        _buildTextField(
            context, widget.password, "Masukkan Password", "password"),
      ],
    );
  }
}
