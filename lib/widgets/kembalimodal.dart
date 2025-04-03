import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:monitoring_guard_frontend/tugas_selection/home_selection.dart';

class KembaliModal extends StatefulWidget {
  final String idRiwayat;
  const KembaliModal({super.key, required this.idRiwayat});

  @override
  State<KembaliModal> createState() => _KembaliModalState();
}

class _KembaliModalState extends State<KembaliModal> {
  bool isLoading = true; // Ini untuk loading spinner
  bool semuaSelesai = false; // Ini untuk cek apakah semua tugas selesai

  @override
  void initState() {
    super.initState();
    cekTugasSelesai(); // Mulai cek tugas selesai saat modal muncul
  }

  Future<void> cekTugasSelesai() async {
    final url = Uri.parse(
        '${dotenv.env['BASE_URL']}/api/tugas/cek-selesai-luar/${widget.idRiwayat}'); // Akses API dengan idRiwayat

    try {
      final response =
          await http.get(url); // Panggil API untuk cek status tugas
      print("📡 API Cek Tugas Response: ${response.statusCode}");

      if (response.statusCode == 200) {
        var data = json.decode(response.body); // Ambil data response
        setState(() {
          semuaSelesai = data['semuaSelesai']; // Set hasil ke state
        });
      }
    } catch (e) {
      print("❌ Error cek tugas: $e");
    } finally {
      setState(() {
        isLoading = false; // Setelah fetch selesai, loading dimatikan
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Saat loading, tampilkan full screen loading
    if (isLoading) {
      return Center(
          child: CircularProgressIndicator()); // Menampilkan loading di tengah
    }

    return Center(
      child: Dialog(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Konfirmasi Kembali",
                style: GoogleFonts.inter(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Text(
                semuaSelesai
                    ? "Apakah Anda yakin ingin kembali ke halaman utama?"
                    : "Tidak bisa kembali! Masih ada tugas yang belum selesai.",
                style: GoogleFonts.inter(),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context), // Tombol Batal
                    child: Text("Batal",
                        style: GoogleFonts.inter(color: Colors.white)),
                    style: TextButton.styleFrom(backgroundColor: Colors.red),
                  ),
                  if (semuaSelesai)
                    TextButton(
                      onPressed: () {
                        // Setelah klik "Ya", menuju ke HomeSelectionScreen
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const HomeSelectionScreen()),
                          (route) => false, // Hapus semua halaman sebelumnya
                        );
                      },
                      child: Text("Ya",
                          style: GoogleFonts.inter(color: Colors.white)),
                      style:
                          TextButton.styleFrom(backgroundColor: Colors.green),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
