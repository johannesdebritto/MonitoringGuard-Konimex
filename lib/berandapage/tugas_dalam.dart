import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:monitoring_guard_frontend/widgets/patroli_dalam_modal.dart';

class TugasDalamScreen extends StatefulWidget {
  const TugasDalamScreen({super.key});

  @override
  State<TugasDalamScreen> createState() => _TugasDalamScreenState();
}

class _TugasDalamScreenState extends State<TugasDalamScreen> {
  List<Map<String, dynamic>> _patroliData = [];
  bool _isLoading = true;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _fetchPatroliData();
  }

  Future<void> _fetchPatroliData() async {
    try {
      final url =
          Uri.parse('${dotenv.env['BASE_URL']}/api/tugas_dalam/patroli-dalam');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> jsonData = json.decode(response.body);
        setState(() {
          _patroliData = List<Map<String, dynamic>>.from(jsonData);
          _isLoading = false;
        });
      } else {
        throw Exception('Gagal mengambil data');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isError = true;
      });
    }
  }

  void _showPatroliDalamModal() async {
    bool? isDataAdded = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return PatroliDalamModal();
      },
    );

    if (isDataAdded == true) {
      _fetchPatroliData();
    }
  }

// Fungsi untuk mengonversi waktu ke format "HH:mm WIB"
  String formatWaktu(String? waktu) {
    if (waktu == null || waktu.isEmpty) return "-";
    try {
      final parsedTime = DateFormat("HH:mm:ss").parse(waktu);
      return DateFormat("HH:mm").format(parsedTime) + " WIB";
    } catch (e) {
      return "-";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 20,
            left: 20,
            child: ElevatedButton.icon(
              onPressed: _showPatroliDalamModal,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE65100),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text(
                'Keterangan Masalah',
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
          Positioned.fill(
            top: 55,
            bottom: 48,
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _isError
                    ? const Center(child: Text("Terjadi kesalahan, coba lagi"))
                    : _patroliData.isEmpty
                        ? const Center(
                            child: Text("Belum ada masalah yang tercatat"))
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _patroliData.length,
                            itemBuilder: (context, index) {
                              final data = _patroliData[index];
                              return _buildPatroliCard(data);
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatroliCard(Map<String, dynamic> data) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.black, width: 1.5),
      ),
      elevation: 5,
      shadowColor: Colors.black54,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.business, color: Colors.black54),
                const SizedBox(width: 8),
                Text(
                  "Bagian: ${data['bagian'] ?? '-'}",
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const Divider(thickness: 1, color: Colors.black45),
            const SizedBox(height: 5),
            Row(
              children: [
                const Icon(Icons.report_problem, color: Colors.redAccent),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Keterangan: ${data['keterangan_masalah'] ?? '-'}",
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Ubah bagian teks waktu di `_buildPatroliCard`
            Row(
              children: [
                const Icon(Icons.access_time, color: Colors.black54),
                const SizedBox(width: 8),
                Text(
                  "Waktu: ${formatWaktu(data['jam_selesai'])}",
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
