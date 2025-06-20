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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 35),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Sejajarkan ke kiri
        children: [
          // Baris pertama: TopBarScreen (title sejajar dengan teks di bawah)
          Padding(
            padding: const EdgeInsets.only(
                bottom: 10), // Jarak sedikit dengan teks berikutnya
            child: TopBarScreen(title: 'Halaman Riwayat'),
          ),

          // Teks tambahan (Hallo & Selamat Bertugas)
          Text(
            'Halo, $namaAnggota 👋',
            style: GoogleFonts.inter(
              fontSize: 23,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Selamat Bertugas di $namaUnit',
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
