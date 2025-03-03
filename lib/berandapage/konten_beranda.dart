import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monitoring_guard_frontend/berandapage/tugas.dart';

class KontenBeranda extends StatefulWidget {
  const KontenBeranda({super.key});

  @override
  _KontenBerandaState createState() => _KontenBerandaState();
}

class _KontenBerandaState extends State<KontenBeranda> {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(35),
            topRight: Radius.circular(35),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              spreadRadius: 5,
              blurRadius: 10,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Row(
                  children: [
                    SvgPicture.asset(
                      'assets/berandaassets/tugas.svg',
                      width: 60,
                      height: 60,
                    ),
                    const SizedBox(width: 1), // Jarak lebih kecil
                    Text(
                      'Tugas Hari Ini !',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      softWrap: true,
                    ),
                  ],
                ),
                const Spacer(),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7F56D9),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 16), // Ukuran diperbesar
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    // Aksi tombol submit
                  },
                  child: Text(
                    "Submit",
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Expanded(
              child: TugasScreen(),
            ),
          ],
        ),
      ),
    );
  }
}
