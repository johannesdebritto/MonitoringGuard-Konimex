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
      namaAnggota = prefs.getString('anggota_terpilih') ??
          prefs.getString('anggota1') ?? // Ambil dari anggota1 kalau tidak ada
          "Anggota Tidak Diketahui";
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
          Padding(
            padding: const EdgeInsets.only(
                bottom: 5), // Jarak sedikit dengan teks berikutnya
            child: TopBarScreen(title: 'Halaman Patroli'),
          ),
          // Teks tambahan (Hallo & Selamat Bertugas)
          Text(
            'Halo, $namaAnggota 👋', // Menampilkan nama anggota yang terpilih
            style: GoogleFonts.inter(
              fontSize: 23, // Diperbesar biar lebih jelas
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
