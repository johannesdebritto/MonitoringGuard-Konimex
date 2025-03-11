import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monitoring_guard_frontend/widgets/TopAppBar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HeaderBeranda extends StatefulWidget {
  const HeaderBeranda({super.key});

  @override
  State<HeaderBeranda> createState() => _HeaderBerandaState();
}

class _HeaderBerandaState extends State<HeaderBeranda> {
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
      namaAnggota =
          prefs.getString('nama_anggota') ?? "Anggota Tidak Diketahui";
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
          const TopBarScreen(),
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
