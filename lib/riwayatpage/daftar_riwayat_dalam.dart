import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:monitoring_guard_frontend/riwayatpage/daftar_riwayat_dalam_logic.dart'; // Pastikan DBHelper sudah benar diimport

class DetailRiwayatDalam extends StatefulWidget {
  const DetailRiwayatDalam({super.key});

  @override
  State<DetailRiwayatDalam> createState() => _DetailRiwayatDalamState();
}

class _DetailRiwayatDalamState extends State<DetailRiwayatDalam> {
  List<dynamic> _riwayatList = [];
  bool _isLoading = false;
  bool _isSubmitted = false;
  final DetailRiwayatDalamService _service = DetailRiwayatDalamService();

  @override
  void initState() {
    super.initState();
    _checkSubmissionStatus();
  }

  Future<void> _checkSubmissionStatus() async {
    bool isSubmitted = await _service.checkSubmissionStatus();
    setState(() {
      _isSubmitted = isSubmitted;
    });
    if (_isSubmitted) {
      await _fetchDetailRiwayatDalam();
    }
  }

  Future<void> _fetchDetailRiwayatDalam() async {
    setState(() {
      _isLoading = true;
    });

    final data = await _service.fetchDetailRiwayatDalam();

    // FILTER DATA KOSONG
    final filteredData = data
        .where((item) =>
            (item['bagian']?.toString().trim().isNotEmpty ?? false) ||
            (item['keterangan_masalah']?.toString().trim().isNotEmpty ??
                false) ||
            (item['jam_selesai']?.toString().trim().isNotEmpty ?? false))
        .toList();

    if (!mounted) return;
    setState(() {
      _riwayatList = filteredData;
      _isLoading = false;
    });
  }

  String _formatWaktu(String? waktu) {
    if (waktu == null || waktu.isEmpty) return '-';
    try {
      final parsedTime = DateFormat.Hms().parse(waktu);
      return DateFormat('HH:mm WIB').format(parsedTime);
    } catch (e) {
      return '-';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : !_isSubmitted || _riwayatList.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(LucideIcons.fileWarning,
                            size: 60, color: Colors.grey),
                        const SizedBox(height: 10),
                        Text(
                          "Tidak ada data",
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Rekap Patroli Dalam",
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const Divider(thickness: 1),
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _riwayatList.length,
                            separatorBuilder: (context, index) =>
                                const Divider(),
                            itemBuilder: (context, index) {
                              final item = _riwayatList[index];
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(LucideIcons.building,
                                            color: Colors.blue, size: 18),
                                        const SizedBox(width: 5),
                                        Text(
                                          "Bagian : ",
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            "${item['bagian'] ?? "(Tidak ada data)"}",
                                            style: GoogleFonts.inter(
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 3),
                                    Row(
                                      children: [
                                        const Icon(LucideIcons.fileText,
                                            color: Colors.green, size: 18),
                                        const SizedBox(width: 5),
                                        Text(
                                          "Keterangan Masalah : ",
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            "${item['keterangan_masalah']?.toString().isNotEmpty == true ? item['keterangan_masalah'] : '-'}",
                                            style: GoogleFonts.inter(
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 3),
                                    Row(
                                      children: [
                                        const Icon(LucideIcons.clock,
                                            color: Colors.orange, size: 18),
                                        const SizedBox(width: 5),
                                        Text(
                                          "Waktu Selesai : ",
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          "${_formatWaktu(item['jam_selesai'])}",
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.blueGrey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }
}
