import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DetailRiwayatScreen extends StatefulWidget {
  final int idRiwayat;
  final List<dynamic> riwayatItem;

  const DetailRiwayatScreen({
    super.key,
    required this.idRiwayat,
    required this.riwayatItem,
  });

  @override
  State<DetailRiwayatScreen> createState() => _DetailRiwayatScreenState();
}

class _DetailRiwayatScreenState extends State<DetailRiwayatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(15),
            bottomRight: Radius.circular(15),
          ),
          child: AppBar(
            automaticallyImplyLeading: false,
            title: Text(
              'Detail Aktivitas Anda',
              style: GoogleFonts.inter(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
            backgroundColor: const Color(0xFFD00000),
            centerTitle: true,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: widget.riwayatItem.map((item) {
                  return _buildActivityCard(
                    item['nama_tugas'] ?? 'Tidak ada nama tugas',
                    item['tanggal_selesai'] ?? '', // Pastikan ini benar
                    item['jam_selesai'] ?? '', // Jam selesai sesuai data
                    item['keterangan_masalah'] ?? '--',
                    item['nama_status'] ?? 'Tidak diketahui',
                  );
                }).toList(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD00000),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Kembali',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(String namaTugas, String tanggalSelesai,
      String jamSelesai, String keterangan, String status) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: Color(0xFF333333), width: 1.5),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(namaTugas,
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 5),
            Text('* Tanggal : ${formatTanggal(tanggalSelesai)}',
                style: GoogleFonts.inter(fontSize: 14)),
            Text('* Jam Selesai : ${cekNull(jamSelesai)}',
                style: GoogleFonts.inter(fontSize: 14)),
            Text('* Keterangan : ${cekNull(keterangan)}',
                style: GoogleFonts.inter(fontSize: 14)),
            const SizedBox(height: 5),
            Row(
              children: [
                statusIcon(status),
                const SizedBox(width: 5),
                Text('Status:',
                    style: GoogleFonts.inter(
                        fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(width: 5),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: getStatusColor(status),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(status,
                      style: GoogleFonts.inter(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String formatTanggal(String isoDate) {
    if (isoDate.isEmpty) return "--";
    try {
      DateTime dateTime = DateTime.parse(isoDate).toLocal();
      return "${dateTime.day} ${_bulan(dateTime.month)} ${dateTime.year}";
    } catch (e) {
      return "--";
    }
  }

  String _bulan(int month) {
    List<String> bulan = [
      "Januari",
      "Februari",
      "Maret",
      "April",
      "Mei",
      "Juni",
      "Juli",
      "Agustus",
      "September",
      "Oktober",
      "November",
      "Desember"
    ];
    return bulan[month - 1];
  }

  String cekNull(String? value) {
    return value == null || value.isEmpty ? "--" : value;
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "selesai":
        return Colors.green;
      case "gagal":
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  Icon statusIcon(String status) {
    switch (status.toLowerCase()) {
      case "selesai":
        return const Icon(Icons.check_circle, color: Colors.green);
      case "gagal":
        return const Icon(Icons.cancel, color: Colors.red);
      default:
        return const Icon(Icons.hourglass_empty, color: Colors.orange);
    }
  }
}
