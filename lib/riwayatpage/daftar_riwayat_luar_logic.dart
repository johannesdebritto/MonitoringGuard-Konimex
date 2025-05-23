import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:monitoring_guard_frontend/riwayatpage/daftar_riwayat_luar.dart';
import 'package:monitoring_guard_frontend/service/db_helper.dart';
import 'package:monitoring_guard_frontend/service/init_db.dart';
import 'package:monitoring_guard_frontend/service/riwayat_luar_helper.dart';

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

    try {
      final db = await InitDb.getDatabase();

      // 🔍 Ambil data terbaru langsung dari SQLite (tanpa fungsi baru)
      final latest = await db.query(
        'riwayat_luar',
        orderBy: 'id_riwayat DESC',
        limit: 1,
      );

      if (latest.isEmpty) {
        setState(() {
          errorMessage = 'Belum ada data riwayat';
          isLoading = false;
        });
        return;
      }

      String idUnit = latest.first['id_unit'].toString();
      String idRiwayat = latest.first['id_riwayat'].toString();

      print("📥 Ambil dari data terbaru: idUnit=$idUnit, idRiwayat=$idRiwayat");

      final localData = await RiwayatLuarHelper.getRiwayatLuarByUnitDanRiwayat(
          idUnit, idRiwayat);
      print("📦 Data lokal hasil filter: $localData");

      setState(() {
        riwayatList = localData;
        namaUnit = localData.first['nama_unit'] ??
            'Unit Tidak Diketahui'; // ✅ Ini ambil dari DB
        this.idRiwayat = idRiwayat;
      });

      // ========================== API FETCH (DISABLE DULU) ==========================
      /*
    final url = Uri.parse('${dotenv.env['BASE_URL']}/api/submit/unit/$idUnit/$idRiwayat');
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
    */
      // =============================================================================
    } catch (e) {
      setState(() {
        errorMessage = 'Terjadi kesalahan saat ambil data';
      });
      print('🚨 Error fetchRiwayat: $e');
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
