import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:monitoring_guard_frontend/authenticationpage/warning_modal.dart';
import 'package:monitoring_guard_frontend/history/history_logic.dart';
import 'package:monitoring_guard_frontend/service/db_helper.dart';
import 'package:monitoring_guard_frontend/service/init_db.dart';
import 'package:monitoring_guard_frontend/service/tugas_unit_helper.dart';
import 'package:monitoring_guard_frontend/tugas_selection/home_selection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:monitoring_guard_frontend/berandapage/tugas_screen_logic.dart';
import 'package:monitoring_guard_frontend/scannernfc/nfc_scanner_logic.dart';

class LoginLogic {
  Future<bool> login({
    required BuildContext context,
    required String email,
    required String password,
    required String anggota1,
    String? anggota2,
    required String patroli,
    required String unitKerja,
  }) async {
    // Validate input fields
    if (email.isEmpty ||
        password.isEmpty ||
        anggota1.isEmpty ||
        patroli.isEmpty ||
        unitKerja.isEmpty) {
      return _showWarningDialog(context,
          "Email, password, anggota1, patroli, dan unit kerja harus diisi");
    }

    try {
      // API call setup
      final url = Uri.parse('${dotenv.env['BASE_URL']}/api/auth/login');
      final body = jsonEncode({
        "email": email,
        "password": password,
        "anggota1": anggota1,
        "anggota2": anggota2?.isNotEmpty == true ? anggota2 : null,
        "patroli": patroli,
        "unit_kerja": unitKerja,
      });

      print("🔵 [LOGIN] Attempting login to: ${url.toString()}");
      print("🔵 [LOGIN] Request body: $body");

      // Execute API call
      final response = await http
          .post(
            url,
            headers: {"Content-Type": "application/json"},
            body: body,
          )
          .timeout(const Duration(seconds: 10));

      print("🔵 [LOGIN] Response status: ${response.statusCode}");
      print("🔵 [LOGIN] Response body: ${response.body}");

      // Handle response
      if (response.statusCode == 200) {
        return await _handleSuccessfulLogin(context, response);
      } else {
        return await _handleLoginError(context, response);
      }
    } catch (e) {
      print("🔴 [LOGIN ERROR] Exception: $e");
      return _showWarningDialog(
          context, "Terjadi kesalahan, periksa koneksi internet");
    }
  }

  Future<bool> _handleSuccessfulLogin(
      BuildContext context, http.Response response) async {
    print("🔵 [LOGIN] Handling successful login");

    // Parse response data
    final data = _parseResponseData(response);
    if (data == null) {
      print("🔴 [LOGIN] Failed to parse response data");
      return false;
    }

    // Initialize SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload(); // Ensure fresh data

    // Generate and save patrol ID
    final idRiwayat = await _generatePatrolId();

    print("🟠 [LOGIN] Generated patrol ID: $idRiwayat");

    try {
      await prefs.setString('id_riwayat', idRiwayat);
      print("🟢 [LOGIN] Patrol ID saved successfully");
    } catch (e) {
      print("🔴 [LOGIN] Failed to save patrol ID: $e");
      return false;
    }

    // Save all login data
    try {
      await Future.wait([
        prefs.setString('id_unit', (data['id_unit'] ?? "").toString()),
        prefs.setString('nama_unit', data['nama_unit'] ?? ""),
        prefs.setString(
            'id_unit_kerja', (data['id_unit_kerja'] ?? "").toString()),
        prefs.setString('anggota1', data['anggota1'] ?? ""),
        prefs.setString('anggota2', data['anggota2'] ?? ""),
        prefs.setString('id_patroli', (data['id_patroli'] ?? "").toString()),
      ]);
      print("🟢 [LOGIN] All login data saved successfully");
    } catch (e) {
      print("🔴 [LOGIN] Error saving login data: $e");
      return false;
    }

    // Fetch additional data
    await _fetchAdditionalData();

    // Navigate to home screen
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeSelectionScreen()),
      );
    }

    return true;
  }

  Future<String> _generatePatrolId() async {
    final db = await InitDb.getDatabase();

    // Cek apakah ada data di tabel riwayat_dalam
    final result =
        await db.rawQuery('SELECT COUNT(*) as count FROM riwayat_dalam');

    int count = result.first['count'] as int;

    // Jika belum ada data, ID pertama akan jadi 1
    if (count == 0) {
      return '1';
    }

    // Jika sudah ada data, ambil ID terakhir dan tambah 1
    final lastResult = await db.rawQuery(
      'SELECT MAX(id_riwayat) as last_id FROM riwayat_dalam',
    );

    int lastId = lastResult.first['last_id'] != null
        ? lastResult.first['last_id'] as int
        : 0;
    int newId = lastId + 1;

    // Simpan ID yang baru ke SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('id_riwayat', newId.toString());

    return newId.toString();
  }

  // -------------------------------------------------------------------------------------------------------------------
  Future<void> _fetchAdditionalData() async {
    print("🔵 [LOGIN] Fetching additional data...");

    // Fetch regular tasks
    try {
      print("🟠 [LOGIN] Fetching regular tasks...");
      List tugasList = await TugasScreenLogic().fetchTugas();
      print("🟢 [LOGIN] Regular tasks fetched successfully");

      if (tugasList.isNotEmpty) {
        for (var tugas in tugasList) {
          if (tugas['id_unit'] != null) {
            // Pastikan id_unit ada
            print("🟠 [LOGIN] Saving task: ${tugas['nama_tugas']}");
            try {
              await TugasUnitHelper.insertTugasUnit({
                'id_unit': tugas['id_unit'],
                'nama_tugas': tugas['nama_tugas'],
                'id_status': tugas['id_status'] ?? 1,
              });
              print("🟢 [LOGIN] Task saved locally: ${tugas['nama_tugas']}");
            } catch (e) {
              print("🔴 [LOGIN] Error saving task ${tugas['nama_tugas']}: $e");
            }
          } else {
            print(
                "🔴 [LOGIN] Task skipped because id_unit is missing: ${tugas['nama_tugas']}");
          }
        }
        print("🟢 [LOGIN] Regular tasks saved locally");
      } else {
        print("🔴 [LOGIN] No regular tasks found.");
      }
    } catch (e) {
      print("🔴 [LOGIN] Error fetching or saving regular tasks: $e");
    }

    // Fetch NFC tasks
    try {
      print("🟠 [LOGIN] Fetching NFC tasks...");
      await NFCScannerLogic
          .fetchTugas(); // ini tetap void, ambil data ke memory
      List<Map<String, dynamic>> nfcTugasList =
          NFCScannerLogic.nfcTasks; // ambil dari variabel class
      print("🟢 [LOGIN] NFC tasks fetched successfully");

      if (nfcTugasList.isNotEmpty) {
        print(
            "🟢 [LOGIN] NFC tasks loaded into memory, no need to save locally.");
        // ❌ Tidak perlu lagi insert ke DB, karena data sudah ada dari regular tasks
      } else {
        print("🔴 [LOGIN] No NFC tasks found.");
      }
    } catch (e) {
      print("🔴 [LOGIN] Error fetching NFC tasks: $e");
    }

    // Fetch history
    try {
      print("🟠 [LOGIN] Fetching history data...");
      await HistoryLogic().fetchAllHistory();
      print("🟢 [LOGIN] History data fetched successfully");
    } catch (e) {
      print("🔴 [LOGIN] Error fetching history: $e");
    }
  }

  Future<bool> _handleLoginError(
      BuildContext context, http.Response response) async {
    print("🔴 [LOGIN] Handling login error");

    String errorMessage = "Gagal login, coba lagi nanti";
    try {
      final errorData = jsonDecode(response.body);
      errorMessage = errorData['message'] ?? errorMessage;
      print("🔴 [LOGIN] Server error: $errorMessage");
    } catch (e) {
      print("🔴 [LOGIN] Error parsing error response: $e");
    }

    return _showWarningDialog(context, errorMessage);
  }

  Map<String, dynamic>? _parseResponseData(http.Response response) {
    try {
      final data = jsonDecode(response.body);
      if (data is! Map<String, dynamic>) {
        throw Exception("Invalid JSON format");
      }
      return data;
    } catch (e) {
      print("🔴 [LOGIN] Error parsing response data: $e");
      return null;
    }
  }

  bool _showWarningDialog(BuildContext context, String message) {
    if (!context.mounted) return false;

    print("🟠 [LOGIN] Showing warning dialog: $message");

    showDialog(
      context: context,
      builder: (context) => WarningModalScreen(
        errors: [message],
        color: Colors.red,
      ),
    );
    return false;
  }
}
