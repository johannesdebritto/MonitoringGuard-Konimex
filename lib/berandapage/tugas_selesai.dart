import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class TugasSelesaiScreen extends StatefulWidget {
  const TugasSelesaiScreen({super.key});

  @override
  State<TugasSelesaiScreen> createState() => _TugasSelesaiScreenState();
}

class _TugasSelesaiScreenState extends State<TugasSelesaiScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        physics:
            BouncingScrollPhysics(), // Memberikan efek scroll yang lebih halus
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 50), // Memberi sedikit jarak dari atas
              SvgPicture.asset(
                'assets/widgetsassets/centang.svg',
                width: 200,
                height: 200,
              ),
              const SizedBox(height: 20),
              Text(
                'Tugas Anda Hari Ini Sudah Selesai',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Terima kasih sudah bertugas',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                  height: 50), // Memberi jarak agar scroll terasa lebih nyaman
            ],
          ),
        ),
      ),
    );
  }
}
