import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:monitoring_guard_frontend/riwayatpage/detail_riwayat_luar.dart';
import 'package:monitoring_guard_frontend/riwayatpage/detail_riwayat_luar_logic.dart';

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
  KontenRiwayatLogic? logic;

  @override
  void initState() {
    super.initState();
    logic = KontenRiwayatLogic(widget.item, () => setState(() {}));
    logic!.init();
  }

  String _formatWaktu(String? waktu) {
    if (waktu == null || waktu.isEmpty) return "-";
    return "$waktu WIB";
  }

  @override
  Widget build(BuildContext context) {
    if (logic == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                  const Divider(thickness: 1, height: 12),
                  _buildTextRow("Hari", widget.item['hari']),
                  _buildTextRow("Tanggal", widget.item['tanggal']),
                  _buildTextRow(
                      "Waktu Mulai",
                      _formatWaktu(
                          widget.item['waktu_mulai_luar']?.toString())),
                  _buildTextRow(
                      "Waktu Selesai",
                      _formatWaktu(
                          widget.item['waktu_selesai_luar']?.toString())),
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
                          widget.item['id_status_luar'] == 2
                              ? 'Selesai'
                              : (widget.item['id_status_luar']?.toString() ??
                                  'Tidak tersedia'),
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ],
                  )
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
                    color: logic!.isLoading
                        ? Colors.grey.shade400
                        : const Color(0xFF7F56D9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: logic!.isLoading
                      ? const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5),
                        )
                      : IconButton(
                          onPressed: () {
                            if (logic!.detailRiwayat.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("⚠️ Belum ada riwayat!"),
                                  backgroundColor: Colors.orange,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                              return;
                            }

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailRiwayatScreen(
                                  idRiwayat: int.tryParse(logic!
                                              .detailRiwayat.first['id_rekap']
                                              ?.toString() ??
                                          '') ??
                                      0,
                                  riwayatItem: logic!.detailRiwayat,
                                ),
                              ),
                            );
                          },
                          icon: SvgPicture.asset(
                            'assets/berandaassets/search.svg',
                            width: 28,
                            height: 28,
                            colorFilter: const ColorFilter.mode(
                                Colors.white, BlendMode.srcIn),
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

  Widget _buildTextRow(String title, dynamic value) {
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
            value?.toString() ?? "Tidak tersedia",
            style: GoogleFonts.inter(fontSize: 14, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
