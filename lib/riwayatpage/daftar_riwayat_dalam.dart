import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

class DaftarRiwayatDalamScreen extends StatefulWidget {
  const DaftarRiwayatDalamScreen({super.key});

  @override
  State<DaftarRiwayatDalamScreen> createState() =>
      _DaftarRiwayatDalamScreenState();
}

class _DaftarRiwayatDalamScreenState extends State<DaftarRiwayatDalamScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.folderOpen,
              size: 48, // Ukuran ikon lebih besar
              color: const Color.fromARGB(255, 0, 0, 0), // Warna ikon
            ),
            const SizedBox(height: 16), // Jarak antara ikon dan teks
            Text(
              'Belum ada riwayat',
              style: GoogleFonts.inter(
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
