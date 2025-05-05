import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:monitoring_guard_frontend/main.dart';
import 'package:monitoring_guard_frontend/scannernfc/nfc_scanner_logic.dart';

class NFCScannerScreen extends StatefulWidget {
  const NFCScannerScreen({super.key});

  @override
  State<NFCScannerScreen> createState() => _NFCScannerScreenState();
}

class _NFCScannerScreenState extends State<NFCScannerScreen> {
  List<dynamic> tugasList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTugas(); // Memanggil fungsi load tugas
  }

  // Mengambil data tugas dan menyimpannya
  Future<void> _loadTugas() async {
    // Memanggil fungsi NFCScannerLogic untuk mengambil tugas
    final data = await NFCScannerLogic.getTugasFromSharedPreferences();

    if (data.isEmpty) {
      // Kalau tidak ada data di SharedPreferences, coba fetch dari API
      await NFCScannerLogic.fetchTugas(); // Fetch data tugas
      final fetchedData = await NFCScannerLogic.getTugasFromSharedPreferences();
      setState(() {
        tugasList = fetchedData; // Menyimpan data tugas yang sudah di-fetch
        isLoading = false;
      });
    } else {
      setState(() {
        tugasList = data; // Menggunakan data yang sudah ada
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan RFID !',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFD00000),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Icon(Iconsax.wifi_outline, size: 80, color: Colors.blueAccent),
            const SizedBox(height: 16),
            Text(
              'Dekatkan HP ke tag RFID',
              style:
                  GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : tugasList.isEmpty
                      ? const Center(
                          child: Text("Tidak ada tugas tersedia scan kosong"))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: tugasList.length,
                          itemBuilder: (context, index) {
                            var tugas = tugasList[index];
                            return _buildTaskItem(tugas, context);
                          },
                        ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MainNavigation(
                      tipePatroli: 'luar',
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Kembali', style: GoogleFonts.inter(fontSize: 16)),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // Menampilkan item tugas dalam bentuk card
  Widget _buildTaskItem(Map<String, dynamic> tugas, BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.blue.shade900),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Expanded(
              child: Text(
                tugas['nama_tugas'],
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900,
                ),
              ),
            ),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () => NFCScannerLogic.showNFCModal(
                    context: context,
                    tugas: tugas,
                    status: "aman",
                    onConfirm: _loadTugas,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  child: Text(
                    'Aman',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => NFCScannerLogic.showNFCModal(
                    context: context,
                    tugas: tugas,
                    status: "masalah",
                    onConfirm: _loadTugas,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  child: Text(
                    'Ada Masalah',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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
}
