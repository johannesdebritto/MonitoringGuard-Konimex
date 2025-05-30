import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:monitoring_guard_frontend/service/db_helper.dart';
import 'package:monitoring_guard_frontend/service/detail_riwayat_dalam_helper.dart';
import 'package:monitoring_guard_frontend/service/riwayat_luar_helper.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:monitoring_guard_frontend/riwayatpage/daftar_riwayat_luar_logic.dart';
import 'package:monitoring_guard_frontend/widgets/modal_submit_luar.dart';

class KontenBerandaLogic {
  bool _isSubmitted = false;
  bool _isSubmittedDalam = false;
  int _jumlahMasalah = 0;

  bool get isSubmitted => _isSubmitted;
  bool get isSubmittedDalam => _isSubmittedDalam;
  int get jumlahMasalah => _jumlahMasalah;

  set isSubmittedDalam(bool value) {
    _isSubmittedDalam = value;
    _saveBool('isSubmittedDalam', value);
  }

  Future<bool> _isOnline() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  Future<int> fetchJumlahMasalah(String idRiwayat) async {
    if (!await _isOnline()) {
      debugPrint('📴 Offline: fetchJumlahMasalah skip HTTP');
      return 0;
    }

    try {
      final url = Uri.parse(
          '${dotenv.env['BASE_URL']}/api/tugas_dalam/patroli-dalam/jumlah/$idRiwayat');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return jsonData['success'] == true
            ? jsonData['jumlah_masalah'] ?? 0
            : 0;
      }
      throw Exception('Gagal mengambil jumlah masalah');
    } catch (e) {
      debugPrint('❌ Error fetching jumlah masalah: $e');
      return 0;
    }
  }

  Future<void> loadStatusDalam() async {
    final prefs = await SharedPreferences.getInstance();
    _isSubmittedDalam = prefs.getBool('isSubmittedDalam') ?? false;
    final idRiwayat = prefs.getString('id_riwayat');
    if (idRiwayat != null) {
      // Ambil data detail riwayat dalam berdasarkan ID
      final riwayatDetail =
          await DetailRiwayatDalamHelper.getDetailRiwayatDalamById(
              int.parse(idRiwayat));
      // Menghitung jumlah masalah berdasarkan jumlah data yang ditemukan
      _jumlahMasalah = riwayatDetail.length;
    } else {
      debugPrint("🚨 ID Riwayat tidak ditemukan, coba login ulang?");
    }
  }

  Future<void> loadStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isSubmitted = prefs.getBool('isSubmitted') ?? false;
  }

  Future<void> fetchStatus() async {
    if (!await _isOnline()) {
      debugPrint("📴 Offline: fetchStatus skip HTTP");
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final idUnit = prefs.getString('id_unit');
      if (idUnit == null) {
        debugPrint("🚨 ID Unit tidak ditemukan, coba login ulang?");
        return;
      }

      final response = await http.get(
          Uri.parse('${dotenv.env['BASE_URL']}/api/tugas/status_data/$idUnit'));
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        _isSubmitted = responseData["success"] == true;
      } else {
        debugPrint("🚨 Gagal mengambil status: ${response.body}");
      }
    } catch (e) {
      debugPrint("🚨 Error fetch status: $e");
    }
  }

  Future<void> submitTugas(BuildContext context,
      {bool showSnackbar = false, bool refreshRiwayat = true}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final idRiwayat = prefs.getString('id_riwayat') ?? '';

      if (idRiwayat.isEmpty) {
        if (showSnackbar) _showSnackbar(context, "🚨 ID Riwayat kosong!");
        return;
      }

      if (!await _isOnline()) {
        debugPrint("📴 Offline: jalankan submit ke SQLite");

        try {
          // Gunakan try-catch untuk tangkap exception spesifik dari database
          await RiwayatLuarHelper
              .submitRiwayatLuar(); // Fungsi ini melempar exception jika belum selesai
          await prefs.setBool('isSubmitted', true);

          if (refreshRiwayat) {
            context
                .findAncestorStateOfType<DaftarRiwayatScreenState>()
                ?.refreshRiwayat();
          }

          if (showSnackbar) {
            _showSnackbar(context, "✅ Submit offline berhasil!", Colors.green);
          }
        } catch (e) {
          debugPrint("❌ Error submit offline: $e");

          // Cek apakah error karena tugas belum selesai (bisa pakai pengecekan isi pesan error)
          if (e.toString().contains('Selesaikan semua tugas')) {
            showDialog(
                context: context, builder: (_) => const ModalSubmitScreen());
          }

          if (showSnackbar) {
            _showSnackbar(context, "🚨 Gagal submit offline: ${e.toString()}");
          }
        }

        return;
      }

      // Kode HTTP dikomentari (aktifkan kembali bila online-only)
      /*
    final response = await http.post(
      Uri.parse('${dotenv.env['BASE_URL']}/api/submit'),
      body: jsonEncode({"id_riwayat": idRiwayat}),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 400) {
      showDialog(context: context, builder: (_) => const ModalSubmitScreen());
      return;
    }

    if (response.statusCode != 200) {
      if (showSnackbar) {
        _showSnackbar(context, "❌ Gagal submit (HTTP ${response.statusCode})");
      }
      return;
    }

    await prefs.setBool('isSubmitted', true);
    if (refreshRiwayat) {
      context
          .findAncestorStateOfType<DaftarRiwayatScreenState>()
          ?.refreshRiwayat();
    }

    if (showSnackbar) {
      _showSnackbar(context, "✅ Berhasil disimpan!", Colors.green);
    }
    */
    } catch (e) {
      debugPrint("❌ Error submit: $e");
      if (showSnackbar) _showSnackbar(context, "🚨 Error: ${e.toString()}");
    }
  }

  void updateJumlahMasalah(int jumlah) {
    _jumlahMasalah = jumlah;
    _saveInt('jumlahMasalah', jumlah);
  }

  Future<void> _saveInt(String key, int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(key, value);
  }

  Future<void> _saveBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  void _showSnackbar(BuildContext context, String message,
      [Color color = Colors.red]) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }
}
