import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

class HistoryLuarView extends StatefulWidget {
  final Map<String, List<dynamic>> groupedHistory;

  const HistoryLuarView({super.key, required this.groupedHistory});

  @override
  State<HistoryLuarView> createState() => _HistoryLuarViewState();
}

class _HistoryLuarViewState extends State<HistoryLuarView> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.groupedHistory.keys.length,
      itemBuilder: (context, index) {
        String idRiwayat = widget.groupedHistory.keys.elementAt(index);
        List<dynamic> items = widget.groupedHistory[idRiwayat]!;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Colors.grey, width: 1),
          ),
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔹 HEADER: Patroli Luar + Tanggal
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(LucideIcons.mapPin, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          'Patroli Luar',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(LucideIcons.calendar, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          _formatTanggal(items[0]['tanggal_selesai']),
                          style: GoogleFonts.inter(fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // 🔹 UNIT
                Row(
                  children: [
                    const Icon(LucideIcons.building, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      'Unit: ${items[0]['nama_unit'] ?? '-'}',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                const Divider(thickness: 1.2, height: 16),

                // 🔹 DETAIL TUGAS
                Column(
                  children: items.map((item) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildRow(LucideIcons.fileText, 'Tugas',
                              item['nama_tugas']),
                          _buildRow(LucideIcons.clock, 'Jam Selesai',
                              item['jam_selesai']),
                          _buildRow(LucideIcons.alertTriangle, 'Masalah',
                              item['keterangan_masalah']),
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Row(
                              children: [
                                Icon(LucideIcons.checkCircle2,
                                    size: 18, color: Colors.grey[700]),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: item['id_status'] == 2
                                          ? Colors.green
                                          : item['id_status'] == 3
                                              ? Colors.red
                                              : Colors.grey,
                                      width: 1.5,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    item['id_status'] == 2
                                        ? 'Selesai'
                                        : item['id_status'] == 3
                                            ? 'Ada Masalah'
                                            : 'Tidak Diketahui',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: item['id_status'] == 2
                                          ? Colors.green
                                          : item['id_status'] == 3
                                              ? Colors.red
                                              : Colors.grey,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Divider(thickness: 0.8, height: 12),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 🔹 Fungsi untuk membuat row dengan ikon dan teks
  Widget _buildRow(IconData icon, String label, dynamic value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[700]),
        const SizedBox(width: 6),
        Text(
          '$label: ${value ?? "-"}',
          style: GoogleFonts.inter(fontSize: 14),
        ),
      ],
    );
  }

  String _formatTanggal(String? rawDate) {
    if (rawDate == null) return '-';
    try {
      DateTime dt = DateTime.parse(rawDate);
      return '${dt.day.toString().padLeft(2, '0')} '
          '${_namaBulan(dt.month)} '
          '${dt.year}';
    } catch (e) {
      return '-';
    }
  }

  String _namaBulan(int bulan) {
    const bulanIndo = [
      '',
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];
    return bulanIndo[bulan];
  }
}
