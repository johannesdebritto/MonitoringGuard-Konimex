import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:monitoring_guard_frontend/riwayatpage/konten_riwayat.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DaftarRiwayatScreen extends StatefulWidget {
  const DaftarRiwayatScreen({Key? key}) : super(key: key);

  @override
  _DaftarRiwayatScreenState createState() => _DaftarRiwayatScreenState();
}

class _DaftarRiwayatScreenState extends State<DaftarRiwayatScreen> {
  List riwayatList = [];
  bool isLoading = true;
  String errorMessage = '';
  String namaUnit = '';

  @override
  void initState() {
    super.initState();
    fetchRiwayat();
  }

  Future<void> fetchRiwayat() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? idUnit = prefs.getString('id_unit');
    namaUnit = prefs.getString('nama_unit') ?? 'Unit Tidak Diketahui';

    if (idUnit == null) {
      setState(() {
        isLoading = false;
        errorMessage = 'ID Unit tidak ditemukan';
      });
      return;
    }

    final url = Uri.parse('${dotenv.env['BASE_URL']}/api/submit/unit/$idUnit');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          riwayatList = json.decode(response.body);
          isLoading = false;
        });
      } else if (response.statusCode == 404) {
        setState(() {
          riwayatList = [];
          isLoading = false;
        });
      } else {
        throw Exception('Gagal mengambil data (${response.statusCode})');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Terjadi kesalahan saat mengambil data';
      });
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(
                  child: Text(errorMessage, style: GoogleFonts.inter()),
                )
              : Padding(
                  padding: EdgeInsets.all(16),
                  child: riwayatList.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                LucideIcons.folderOpen,
                                size: 48, // Ukuran ikon lebih besar
                                color: const Color.fromARGB(255, 0, 0,
                                    0), // Warna ikon agar tidak mencolok
                              ),
                              SizedBox(
                                  height: 10), // Jarak antara ikon dan teks
                              Text(
                                'Tidak ada riwayat Tugas',
                                style: GoogleFonts.inter(
                                  fontSize: 18, // Perbesar ukuran font
                                  fontWeight: FontWeight.bold, // Tebalkan teks
                                  color: const Color.fromARGB(255, 0, 0,
                                      0), // Warna teks sedikit lebih lembut
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: riwayatList.length,
                          itemBuilder: (context, index) {
                            return KontenRiwayatScreen(
                              item: riwayatList[index],
                              namaUnit: namaUnit,
                            );
                          },
                        ),
                ),
    );
  }
}
