import 'package:flutter/material.dart';

class DetailRiwayatScreen extends StatelessWidget {
  const DetailRiwayatScreen({super.key});

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
            automaticallyImplyLeading: false, // Menghapus tombol kembali
            title: const Text(
              'Detail Aktivitas Anda !',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            backgroundColor:
                const Color(0xFFD00000), // Warna merah yang diminta
            centerTitle: true,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildActivityCard(
                'Mulai Pengecekan', '09.00 WIB', '24 Februari 2025', '-'),
            _buildActivityCard(
                'Pengecekan Gedung A', '09.30 WIB', '24 Februari 2025', '-'),
            _buildActivityCard(
                'Pengecekan Gedung B', '10.00 WIB', '24 Februari 2025', '-'),
            _buildActivityCard(
                'Pengecekan Gedung C', '10.30 WIB', '24 Februari 2025', '-'),
            _buildActivityCard('Pengecekan Gedung D', '12.30 WIB',
                '24 Februari 2025', 'Lampu Mati'),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF7F56D9),
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Kembali',
                  style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard(
      String title, String time, String date, String note) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 5),
            Text('* Waktu Selesai  : $time',
                style: const TextStyle(fontSize: 14)),
            Text('* Tanggal Selesai : $date',
                style: const TextStyle(fontSize: 14)),
            Text('* Keterangan      : $note',
                style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 5),
            Row(
              children: [
                const Text('Status:',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(width: 5),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('Selesai',
                      style: TextStyle(
                          color: Colors.green, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
