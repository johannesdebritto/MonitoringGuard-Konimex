import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:monitoring_guard_frontend/authenticationpage/login.dart';

class TopBarScreen extends StatefulWidget {
  final String title;
  const TopBarScreen({super.key, required this.title});

  @override
  State<TopBarScreen> createState() => _TopBarScreenState();
}

class _TopBarScreenState extends State<TopBarScreen> {
  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // 🔥 Hapus semua data

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFD00000),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.title,
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          ElevatedButton.icon(
            onPressed: _logout,
            icon: SvgPicture.asset(
              'assets/berandaassets/logout.svg',
              width: 25,
              height: 25,
              color: Colors.white,
            ),
            label: Text(
              'Logout',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD00000),
              side: const BorderSide(color: Colors.white, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
