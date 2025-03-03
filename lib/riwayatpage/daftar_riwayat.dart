import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monitoring_guard_frontend/riwayatpage/detail_riwayat.dart';

class DaftarRiwayatScreen extends StatefulWidget {
  const DaftarRiwayatScreen({super.key});

  @override
  State<DaftarRiwayatScreen> createState() => _DaftarRiwayatScreenState();
}

class _DaftarRiwayatScreenState extends State<DaftarRiwayatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          buildTaskItem(
            'Shift Pengecekan',
            'Senin',
            '26 Februari 2024',
            '08:00 - 16:00',
            'Selesai',
            Colors.green.shade200,
          ),
        ],
      ),
    );
  }

  Widget buildTaskItem(String title, String day, String date, String time,
      String status, Color statusColor) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.blue.shade900),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Text('\u2022 '),
                      Text('Hari: $day', style: GoogleFonts.inter()),
                    ],
                  ),
                  Row(
                    children: [
                      const Text('\u2022 '),
                      Text('Tanggal: $date', style: GoogleFonts.inter()),
                    ],
                  ),
                  Row(
                    children: [
                      const Text('\u2022 '),
                      Text('Waktu: $time', style: GoogleFonts.inter()),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('\u2022 '),
                      Text(
                        'Status: ',
                        style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(status, style: GoogleFonts.inter()),
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
                    color: Colors.black, // Bisa diubah sesuai kebutuhan
                  ),
                ),
                const SizedBox(height: 2), // Jarak antara teks dan tombol
                Container(
                  decoration: BoxDecoration(
                    color: Color(0xFF7F56D9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DetailRiwayatScreen()),
                      );
                    },
                    icon: const Icon(Icons.search, color: Colors.white),
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
