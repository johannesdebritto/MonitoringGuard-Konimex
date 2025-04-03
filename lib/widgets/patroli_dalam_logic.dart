import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PatroliDalamLogic {
  Future<bool> submitPatroliDalam(
    BuildContext context,
    String bagian,
    String keterangan,
  ) async {
    if (bagian.isEmpty || keterangan.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Bagian dan keterangan tidak boleh kosong")),
      );
      return false;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? namaAnggota = prefs.getString('anggota_terpilih');
    String? idRiwayatString = prefs.getString('id_riwayat');
    int? idRiwayat = idRiwayatString != null
        ? int.tryParse(idRiwayatString)
        : prefs.getInt('id_riwayat');

    if (namaAnggota == null || idRiwayat == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Anggota atau ID Riwayat belum dipilih")),
      );
      return false;
    }

    final url = Uri.parse(
        '${dotenv.env['BASE_URL']}/api/tugas_dalam/submit-patroli-dalam');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "id_riwayat": idRiwayat,
        "nama_anggota": namaAnggota,
        "id_status": 3,
        "bagian": bagian,
        "keterangan_masalah": keterangan,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Patroli dalam berhasil disimpan")),
      );

      return true; // ✅ Tidak ada refresh daftar riwayat
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Gagal menyimpan patroli dalam: ${response.body}")),
      );
      return false;
    }
  }
}
