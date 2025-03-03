import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_form.dart'; // 🆕 Import LoginForm

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset:
          false, // ✅ Background tetap saat keyboard muncul
      body: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 🎨 Background dua warna
            Column(
              children: [
                Expanded(
                  child: Container(color: Colors.white),
                ),
                Expanded(
                  child: Container(color: const Color(0xFFD00000)),
                ),
              ],
            ),

            // 🌟 Logo dan teks di atas box
            Positioned(
              top: MediaQuery.of(context).size.height / 2 - 430,
              child: Column(
                children: [
                  Transform.translate(
                    offset: const Offset(15, 0),
                    child: SvgPicture.asset(
                      'assets/loginassets/logo_konimex.svg',
                      width: 300,
                      height: 350,
                    ),
                  ),
                  Transform.translate(
                    offset: const Offset(0, -135),
                    child: Text(
                      "MONITORING GUARD",
                      style: GoogleFonts.inter(
                        fontSize: 23,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                        height: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 🏛️ Box LoginForm di tengah
            Positioned(
              top: MediaQuery.of(context).size.height / 2 - 175,
              child: const LoginForm(), // 🆕 Panggil LoginForm
            ),
          ],
        ),
      ),
    );
  }
}
