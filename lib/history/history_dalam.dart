import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

class HistoryDalamView extends StatefulWidget {
  final Map<String, List<dynamic>> groupedHistory;

  const HistoryDalamView({super.key, required this.groupedHistory});

  @override
  State<HistoryDalamView> createState() => _HistoryDalamViewState();
}

class _HistoryDalamViewState extends State<HistoryDalamView> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.groupedHistory.keys.length,
      itemBuilder: (context, index) {
        String idRiwayat = widget.groupedHistory.keys.elementAt(index);
        List<dynamic> items = widget.groupedHistory[idRiwayat]!;
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Colors.grey, width: 1),
          ),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(LucideIcons.shield),
                        const SizedBox(width: 5),
                        const Text('Patroli Dalam',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(LucideIcons.calendar),
                        const SizedBox(width: 5),
                        Text(
                          items[0]['tanggal_selesai'] ?? '-',
                          style: GoogleFonts.inter(fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
                const Divider(),
                Column(
                  children: items.map((item) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(LucideIcons.layout),
                              const SizedBox(width: 5),
                              Text('Bagian: ${item['bagian'] ?? '-'}',
                                  style: GoogleFonts.inter()),
                            ],
                          ),
                          Row(
                            children: [
                              const Icon(LucideIcons.alertCircle),
                              const SizedBox(width: 5),
                              Text(
                                  'Keterangan: ${item['keterangan_masalah'] ?? '-'}',
                                  style: GoogleFonts.inter()),
                            ],
                          ),
                          Row(
                            children: [
                              const Icon(LucideIcons.clock),
                              const SizedBox(width: 5),
                              Text('Waktu: ${item['jam_selesai'] ?? '-'}',
                                  style: GoogleFonts.inter()),
                            ],
                          ),
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
}
