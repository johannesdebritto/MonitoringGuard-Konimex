import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monitoring_guard_frontend/authenticationpage/login.dart';

class HeaderBeranda extends StatelessWidget {
  const HeaderBeranda({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFD00000),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Biar teks rata kiri
        children: [
          // Baris pertama: "Halaman Beranda" & Logout dengan ikon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Halaman Beranda',
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                        builder: (context) => const LoginScreen()),
                  );
                  // Tambahkan fungsi logout di sini
                },
                icon: SvgPicture.asset(
                  'assets/berandaassets/logout.svg',
                  width: 25,
                  height: 25,
                  color: Colors.white,
                ),
                label: Text(
                  'Logout',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD00000),
                  side: const BorderSide(color: Colors.white, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5), // Jarak agar teks di bawahnya terlihat

          // Teks tambahan (Hallo & Selamat Bertugas)
          Text(
            'Hallo Username', // Ganti dengan variabel username jika ada
            style: GoogleFonts.inter(
              fontSize: 25, // Diperbesar biar lebih jelas
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Selamat Bertugas di Gedung Farmasi A', // Bisa diganti dengan gedung yang sesuai
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
