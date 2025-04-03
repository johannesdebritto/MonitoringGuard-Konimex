import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:monitoring_guard_frontend/riwayatpage/daftar_riwayat_luar.dart';

import 'package:shared_preferences/shared_preferences.dart';

class DaftarRiwayatScreen extends StatefulWidget {
  const DaftarRiwayatScreen({Key? key}) : super(key: key);

  @override
  DaftarRiwayatScreenState createState() => DaftarRiwayatScreenState();
}

class DaftarRiwayatScreenState extends State<DaftarRiwayatScreen> {
  List riwayatList = [];
  bool isLoading = true;
  String errorMessage = '';
  String namaUnit = 'Unit Tidak Diketahui';
  String? idRiwayat; // Menambahkan idRiwayat

  @override
  void initState() {
    super.initState();
    fetchRiwayat();
  }

  void refreshRiwayat() {
    fetchRiwayat();
  }

  Future<void> fetchRiwayat() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isSubmitted =
        prefs.getBool('isSubmitted') ?? false; // 🔥 Cek apakah sudah submit
    String? idUnit = prefs.getString('id_unit')?.trim();
    String? namaUnitPref = prefs.getString('nama_unit')?.trim();
    String? storedIdRiwayat =
        prefs.getString('id_riwayat')?.trim(); // Ambil idRiwayat

    if (!isSubmitted) {
      print("🚫 Belum submit, gak fetch riwayat.");
      setState(() {
        isLoading = false;
        riwayatList = [];
      });
      return;
    }

    if (idUnit == null || idUnit.isEmpty) {
      setState(() {
        isLoading = false;
        errorMessage = 'ID Unit tidak ditemukan';
      });
      print("🚨 ID Unit tidak ditemukan");
      return;
    }

    if (storedIdRiwayat == null || storedIdRiwayat.isEmpty) {
      setState(() {
        isLoading = false;
        errorMessage = 'ID Riwayat tidak ditemukan';
      });
      print("🚨 ID Riwayat tidak ditemukan");
      return;
    }

    setState(() {
      namaUnit = namaUnitPref ?? 'Unit Tidak Diketahui';
      idRiwayat =
          storedIdRiwayat; // Pastikan idRiwayat memiliki nilai yang valid
    });

    // Debug log sebelum request
    print(
        "🌍 Fetching from URL: ${dotenv.env['BASE_URL']}/api/submit/unit/$idUnit/$idRiwayat");

    final url = Uri.parse(
        '${dotenv.env['BASE_URL']}/api/submit/unit/$idUnit/$idRiwayat');

    try {
      final response = await http.get(url);
      print("📡 Fetch Riwayat Response: ${response.statusCode}");

      if (response.statusCode == 200) {
        var decodedBody = json.decode(response.body);
        print("📋 Data Riwayat: $decodedBody");

        if (decodedBody is List) {
          setState(() {
            riwayatList = decodedBody;
          });
        } else {
          setState(() {
            errorMessage = 'Format data tidak valid';
          });
        }
      } else if (response.statusCode == 404) {
        setState(() {
          riwayatList = [];
          errorMessage = 'Riwayat tidak ditemukan';
        });
      } else {
        throw Exception('Gagal mengambil data (${response.statusCode})');
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Terjadi kesalahan saat mengambil data';
      });
      print('🚨 Error Fetch Riwayat: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(
                  child: Text(
                    errorMessage,
                    style: GoogleFonts.inter(fontSize: 16, color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                )
              : riwayatList.isEmpty
                  ? _buildEmptyState()
                  : _buildRiwayatList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(LucideIcons.folderOpen, size: 48, color: Colors.black),
          const SizedBox(height: 10),
          Text(
            'Tidak ada riwayat Tugas',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiwayatList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: riwayatList.length,
      itemBuilder: (context, index) {
        return KontenRiwayatScreen(
          item: riwayatList[index] ?? {},
          namaUnit: namaUnit,
        );
      },
    );
  }
}
