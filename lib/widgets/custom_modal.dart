import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomModalWidgets extends StatelessWidget {
  final String status;

  const CustomModalWidgets({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    // Menentukan warna berdasarkan status
    Color statusColor;
    String waktuSelesai = '09.00 WIB';
    String tanggalSelesai = '25 Februari 2025';
    List<String> masalahList = [];

    if (status == "Selesai") {
      statusColor = const Color(0xFFF38b000);
    } else if (status == "Belum Selesai") {
      statusColor = const Color(0xFFFCA311);
      waktuSelesai = '--';
      tanggalSelesai = '--';
    } else {
      // Ada Masalah
      statusColor = const Color(0xFFD00000);
      waktuSelesai = '--';
      tanggalSelesai = '--';
      masalahList = ["Masalah 1", "Masalah 2", "Masalah 3"];
    }

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(2, 2),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.info_outline, color: Colors.black54),
                ),
                const SizedBox(width: 8),
                Text(
                  'Detail Aktivitas',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTextField('Nama Petugas', 'Brian'),
            _buildTextField('Tugas', 'Shift Pengecekan'),
            _buildTextField('Waktu Selesai', waktuSelesai),
            _buildTextField('Tanggal Selesai', tanggalSelesai),
            Text(
              'Status',
              style: GoogleFonts.inter(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(
                status,
                style: GoogleFonts.inter(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (status == "Ada Masalah") ...[
              const SizedBox(height: 10),
              _buildTextField('Keterangan Masalah', masalahList.join('\n')),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7F56D9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: Center(
                child: Text(
                  'Tutup',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        TextField(
          readOnly: true,
          maxLines: null,
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            filled: true,
            fillColor: Colors.white,
            hintText: value,
            hintStyle:
                GoogleFonts.inter(fontWeight: FontWeight.w600), // Semi-bold
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
