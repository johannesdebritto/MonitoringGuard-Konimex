import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:monitoring_guard_frontend/riwayatpage/detail_riwayat.dart';

class KontenRiwayatScreen extends StatefulWidget {
  final Map<String, dynamic> item;
  final String namaUnit;

  const KontenRiwayatScreen({
    Key? key,
    required this.item,
    required this.namaUnit,
  }) : super(key: key);

  @override
  State<KontenRiwayatScreen> createState() => _KontenRiwayatScreenState();
}

class _KontenRiwayatScreenState extends State<KontenRiwayatScreen> {
  List<dynamic>?
      detailRiwayat; // Change to List<dynamic> instead of Map<String, dynamic>
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    print("🟠 [DEBUG] widget.item sebelum fetch: ${widget.item}");

    if (widget.item != null && widget.item['id_unit'] != null) {
      fetchDetailRiwayat();
    } else {
      print("❌ [ERROR] widget.item atau id_unit NULL!");
    }
  }

  Future<void> fetchDetailRiwayat() async {
    try {
      final idUnit = widget.item['id_unit']; // AMBIL ID_UNIT
      print(
          "🔵 [DEBUG] Mengambil data dari detail_riwayat dengan id_unit: $idUnit");

      final url = Uri.parse(
          '${dotenv.env['BASE_URL']}/api/tugas/detail_riwayat/$idUnit');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print("✅ [SUCCESS] Data detail_riwayat diterima: $data");

        if (mounted) {
          setState(() {
            detailRiwayat = data;
            isLoading = false;
          });
        }
      } else {
        print(
            "❌ [ERROR] Gagal mengambil data. Status code: ${response.statusCode}");
        print("❗ [DEBUG] Response body: ${response.body}");

        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print("🔥 [EXCEPTION] Error saat mengambil data: $e");

      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Pengecekan ${widget.namaUnit}",
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                    ),
                  ),
                  Divider(thickness: 1, height: 12),
                  _buildTextRow("Hari", widget.item['hari']),
                  _buildTextRow("Tanggal", widget.item['tanggal']),
                  _buildTextRow("Waktu Mulai", widget.item['waktu_mulai']),
                  _buildTextRow("Waktu Selesai", widget.item['waktu_selesai']),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        "Status: ",
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.green, width: 1.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          widget.item['nama_status'],
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              children: [
                Text(
                  'Detail',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Container(
                  decoration: BoxDecoration(
                    color: isLoading
                        ? Colors.grey.shade400 // Warna abu-abu jika loading
                        : const Color(0xFF7F56D9), // Warna utama jika aktif
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: isLoading
                      ? Padding(
                          padding: const EdgeInsets.all(
                              8.0), // Biar loadingnya nggak terlalu kecil
                          child: const CircularProgressIndicator(
                            color: Colors.white, // Warna loading
                            strokeWidth: 2.5,
                          ),
                        )
                      : IconButton(
                          onPressed: () {
                            if (detailRiwayat == null ||
                                detailRiwayat!.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text("⚠️ Data detail tidak ditemukan!"),
                                  backgroundColor: Colors.orange,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                              return;
                            }

                            // Ambil data pertama dari detailRiwayat sebagai contoh
                            final firstDetail = detailRiwayat!.first;

                            print(
                                "🔍 [DEBUG] Data yang dikirim ke DetailRiwayatScreen: $firstDetail");

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailRiwayatScreen(
                                  idRiwayat: firstDetail[
                                      'id_rekap'], // Gunakan id_rekap dari detailRiwayat
                                  riwayatItem: detailRiwayat!,
                                ),
                              ),
                            );
                          },
                          icon: SvgPicture.asset(
                            'assets/berandaassets/search.svg',
                            width: 28,
                            height: 28,
                            colorFilter: const ColorFilter.mode(
                              Colors
                                  .white, // Ikon warna putih agar kontras dengan background
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            "$title: ",
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(fontSize: 14, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
