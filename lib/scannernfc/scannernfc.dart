import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:monitoring_guard_frontend/main.dart';
import 'package:monitoring_guard_frontend/widgets/modal_nfc.dart'; // Import modal
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

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
    fetchTugas();
  }

  // Ambil data tugas dari backend berdasarkan id_unit
  Future<void> fetchTugas() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? idUnit = prefs.getString('id_unit');

      if (idUnit == null) {
        print("ID Unit tidak ditemukan");
        setState(() {
          isLoading = false;
        });
        return;
      }

      final response = await http.get(
        Uri.parse('${dotenv.env['BASE_URL']}/api/tugas/$idUnit'),
      );

      if (response.statusCode == 200) {
        setState(() {
          tugasList = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        print("Gagal mengambil data tugas");
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  // Fungsi untuk update status setelah konfirmasi di modal
  void showNFCModal(Map<String, dynamic> tugas, String status) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return NFCModalScreen(
          status: status, // "aman" atau "masalah"
          idTugas: tugas['id_tugas'].toString(),
          onConfirm: fetchTugas, // Refresh daftar tugas setelah update
        );
      },
    );
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
                  ? Center(child: CircularProgressIndicator())
                  : tugasList.isEmpty
                      ? Center(child: Text("Tidak ada tugas tersedia"))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: tugasList.length,
                          itemBuilder: (context, index) {
                            var tugas = tugasList[index];
                            return buildTaskItem(tugas);
                          },
                        ),
            ),
            const SizedBox(height: 16),

// Tombol kembali ke MainNavigation
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MainNavigation(
                      tipePatroli: 'luar', // Ganti dengan tipe yang sesuai
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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

  // Widget untuk menampilkan item tugas (nama tugas di kiri, tombol di kanan)
  Widget buildTaskItem(Map<String, dynamic> tugas) {
    String title = tugas['nama_tugas'];

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
            // Nama Tugas (pojok kiri)
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900,
                ),
              ),
            ),
            // Tombol "Aman" dan "Ada Masalah" (pojok kanan, berjejeran)
            Row(
              children: [
                ElevatedButton(
                  onPressed: () => showNFCModal(tugas, "aman"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8), // Ukuran tombol
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
                const SizedBox(width: 8), // Jarak antara tombol
                ElevatedButton(
                  onPressed: () => showNFCModal(tugas, "masalah"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8), // Ukuran tombol
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
