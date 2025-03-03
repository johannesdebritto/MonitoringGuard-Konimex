import 'package:flutter/material.dart';
import 'header_beranda.dart';
import 'konten_beranda.dart';

class BerandaScreen extends StatefulWidget {
  const BerandaScreen({super.key});

  @override
  State<BerandaScreen> createState() => _BerandaScreenState();
}

class _BerandaScreenState extends State<BerandaScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD00000), // Background merah
      body: Column(
        children: [
          // Bagian merah (Header) pakai Flexible biar adaptif
          Flexible(
            flex: 3, // Bisa disesuaikan
            child: Container(
              color: const Color(0xFFD00000),
              child: const HeaderBeranda(),
            ),
          ),

          // Bagian putih (Konten utama)
          Expanded(
            flex: 8, // Bisa disesuaikan kalau masih kurang pas
            child: const KontenBeranda(),
          ),
        ],
      ),
    );
  }
}
