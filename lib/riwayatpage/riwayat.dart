import 'package:flutter/material.dart';
import 'package:monitoring_guard_frontend/riwayatpage/riwayat_header.dart';
import 'package:monitoring_guard_frontend/riwayatpage/riwayat_konten.dart';

class RiwayatScreen extends StatefulWidget {
  const RiwayatScreen({super.key});

  @override
  State<RiwayatScreen> createState() => _RiwayatScreenState();
}

class _RiwayatScreenState extends State<RiwayatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD00000), // Background merah
      body: Column(
        children: [
          // Bagian merah (Kurangi dikit biar muat)
          Flexible(
            flex: 3, // Bisa disesuaikan
            child: Container(
              color: const Color(0xFFD00000),
              child: const RiwayatHeaderScreen(),
            ),
          ),

          // Bagian putih (Tetap seperti sebelumnya)
          Expanded(
            flex: 8, // Bisa ubah 7 ke 7.5 kalau mau lebih turun
            child: const RiwayatKontenScreen(),
          ),
        ],
      ),
    );
  }
}
