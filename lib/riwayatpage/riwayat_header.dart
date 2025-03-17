import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monitoring_guard_frontend/widgets/TopAppBar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RiwayatHeaderScreen extends StatefulWidget {
  const RiwayatHeaderScreen({super.key});

  @override
  State<RiwayatHeaderScreen> createState() => _RiwayatHeaderScreenState();
}

class _RiwayatHeaderScreenState extends State<RiwayatHeaderScreen> {
  String namaAnggota = "";
  String namaUnit = "";

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Panggil fungsi untuk ambil data dari SharedPreferences
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      namaAnggota = prefs.getString('anggota1') ?? "Anggota Tidak Diketahui";
      namaUnit = prefs.getString('nama_unit') ?? "Unit Tidak Diketahui";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFD00000),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Biar teks rata kiri
        children: [
          // Baris pertama: "Halaman Beranda" & Logout (dari TopBarScreen)
          const TopBarScreen(title: 'Halaman Riwayat'),

          const SizedBox(height: 2), // Jarak agar teks di bawahnya terlihat

          // Teks tambahan (Hallo & Selamat Bertugas)
          Text(
            'Halo, $namaAnggota 👋', // Pakai nama anggota dari SharedPreferences
            style: GoogleFonts.inter(
              fontSize: 25, // Diperbesar biar lebih jelas
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Selamat Bertugas di $namaUnit', // Nama unit dari SharedPreferences
            style: GoogleFonts.inter(
              fontSize: 22, // Diperbesar biar lebih nyaman dibaca
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
