import 'package:flutter/material.dart';
import 'header_beranda.dart';
import 'konten_beranda.dart';

class BerandaScreen extends StatefulWidget {
  final String tipePatroli; // Tambahkan parameter tipe

  const BerandaScreen({super.key, required this.tipePatroli});

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
          // Bagian merah (Header)
          Flexible(
            flex: 3,
            child: Container(
              color: const Color(0xFFD00000),
              child: const HeaderBeranda(),
            ),
          ),

          // Bagian putih (Konten utama), sekarang meneruskan tipePatroli
          Expanded(
            flex: 8,
            child: KontenBeranda(tipePatroli: widget.tipePatroli),
          ),
        ],
      ),
    );
  }
}
