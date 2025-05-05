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
  bool isLoading = true;
  bool bolehKeluar = false;

  @override
  void initState() {
    super.initState();
    cekTugasSelesai();
  }

  Future<void> cekTugasSelesai() async {
    final url = Uri.parse(
        '${dotenv.env['BASE_URL']}/api/tugas/cek-selesai-luar/${widget.idRiwayat}');

    try {
      final response = await http.get(url);
      print("📡 API Cek Tugas Response: ${response.statusCode}");

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        print("📥 Response JSON: $data");

        int total = data['totalTugas'] ?? 0;
        int selesai = data['tugasSelesai'] ?? 0;

        print("📊 totalTugas: $total, tugasSelesai: $selesai");

        // Logika utama: boleh keluar jika selesai == 0 atau selesai == total
        setState(() {
          bolehKeluar = (selesai == 0 || selesai == total);
        });
      }
    } catch (e) {
      print("❌ Error cek tugas: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
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
                bolehKeluar
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
                    onPressed: () => Navigator.pop(context),
                    child: Text("Batal",
                        style: GoogleFonts.inter(color: Colors.white)),
                    style: TextButton.styleFrom(backgroundColor: Colors.red),
                  ),
                  if (bolehKeluar)
                    TextButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const HomeSelectionScreen()),
                          (route) => false,
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
