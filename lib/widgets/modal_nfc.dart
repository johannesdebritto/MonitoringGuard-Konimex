import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class NFCModalScreen extends StatefulWidget {
  final String status; // "aman" atau "masalah"

  const NFCModalScreen({super.key, required this.status});

  @override
  State<NFCModalScreen> createState() => _NFCModalScreenState();
}

class _NFCModalScreenState extends State<NFCModalScreen> {
  final TextEditingController _keteranganController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    bool isMasalah = widget.status == "masalah";

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Gambar sesuai status
            SvgPicture.asset(
              isMasalah
                  ? 'assets/widgetsassets/danger.svg' // Gambar untuk "masalah"
                  : 'assets/widgetsassets/centang.svg', // Gambar untuk "aman"
              width: 80,
              height: 80,
            ),
            const SizedBox(height: 16),

            // Judul Modal
            Text(
              isMasalah ? "Lokasi Terdapat Masalah" : "Lokasi Aman",
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Deskripsi Modal
            Text(
              isMasalah
                  ? "Segera Tuliskan Keterangan Masalah Agar Bisa Ditindak Lanjuti!"
                  : "Terima Kasih Sudah Bertugas!",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),

            // Jika statusnya "masalah", tampilkan input keterangan
            if (isMasalah) ...[
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Keterangan Masalah",
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _keteranganController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "Tulis keterangan masalah...",
                  hintStyle: GoogleFonts.inter(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 20),

            // Tombol Konfirmasi
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Menutup modal
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7F56D9), // Warna tombol
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  "Konfirmasi",
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
