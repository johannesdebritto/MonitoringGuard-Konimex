import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:monitoring_guard_frontend/widgets/kembalimodal.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TopBarScreen extends StatefulWidget {
  final String title;
  const TopBarScreen({super.key, required this.title});

  @override
  State<TopBarScreen> createState() => _TopBarScreenState();
}

class _TopBarScreenState extends State<TopBarScreen> {
  void _showExitConfirmation() async {
    // Ambil idRiwayat sebelum menampilkan modal
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? idRiwayat =
        prefs.getString('id_riwayat'); // Ambil idRiwayat dari SharedPreferences

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return KembaliModal(
          idRiwayat:
              idRiwayat ?? '', // Pastikan idRiwayat ada, jika tidak kosongkan
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
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
          onPressed: _showExitConfirmation, // Tampilkan modal saat diklik
          icon: SvgPicture.asset(
            'assets/berandaassets/logout.svg',
            width: 25,
            height: 25,
            color: Colors.white,
          ),
          label: Text(
            'Keluar',
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
    );
  }
}
