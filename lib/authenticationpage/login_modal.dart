import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';

class LoginModalScreen extends StatefulWidget {
  final String initialValue;
  final String fieldType; // email, password, pegawai

  const LoginModalScreen({
    super.key,
    required this.initialValue,
    required this.fieldType,
  });

  @override
  State<LoginModalScreen> createState() => _LoginModalScreenState();
}

class _LoginModalScreenState extends State<LoginModalScreen> {
  late TextEditingController _controller;
  bool _obscure = true; // Untuk password

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.fieldType == "password"
                  ? "Masukkan Password"
                  : "Masukkan Data",
              style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              obscureText: widget.fieldType == "password" ? _obscure : false,
              autofocus: true,
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                suffixIcon: widget.fieldType == "password"
                    ? IconButton(
                        icon: Icon(
                          _obscure
                              ? Iconsax.eye_slash_outline
                              : Iconsax.eye_outline,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscure = !_obscure;
                          });
                        },
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text("Batal",
                      style: GoogleFonts.inter(color: Colors.white)),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF38B000),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    Navigator.pop(context, _controller.text);
                  },
                  child: Text("Simpan",
                      style: GoogleFonts.inter(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
