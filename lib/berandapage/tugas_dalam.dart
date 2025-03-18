import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TugasDalamScreen extends StatefulWidget {
  const TugasDalamScreen({super.key});

  @override
  State<TugasDalamScreen> createState() => _TugasDalamScreenState();
}

class _TugasDalamScreenState extends State<TugasDalamScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Placeholder(), // Konten layar

          // Tombol di pojok kanan atas
          Positioned(
            top: 20, // Jarak dari atas
            right: 20, // Jarak dari kanan
            child: ElevatedButton.icon(
              onPressed: () {
                // Aksi ketika tombol ditekan
              },
              style: ElevatedButton.styleFrom(
                primary: const Color(0xFFFD8D20), // Warna orange agak tua
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              icon: const Icon(
                Icons.add,
                color: Colors.white,
              ),
              label: Text(
                'Keterangan Masalah',
                style: GoogleFonts.inter(
                  textStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
