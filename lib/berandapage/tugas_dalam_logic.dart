import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:monitoring_guard_frontend/widgets/patroli_dalam_modal.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TugasDalamLogic {
  Future<int> fetchJumlahMasalah(String idRiwayat) async {
    try {
      final url = Uri.parse(
          '${dotenv.env['BASE_URL']}/api/tugas_dalam/patroli-dalam/jumlah/$idRiwayat');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return jsonData['success'] == true
            ? jsonData['jumlah_masalah'] ?? 0
            : 0;
      } else {
        throw Exception('Gagal mengambil jumlah masalah');
      }
    } catch (e) {
      print('❌ Error fetching jumlah masalah: $e');
      return 0;
    }
  }

  Future<List<Map<String, dynamic>>> fetchPatroliData(String idRiwayat) async {
    try {
      final url = Uri.parse(
          '${dotenv.env['BASE_URL']}/api/tugas_dalam/patroli-dalam/$idRiwayat');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true) {
          return List<Map<String, dynamic>>.from(jsonData['data']);
        }
      }
    } catch (e) {
      print('❌ Error fetching patroli data: $e');
    }
    return [];
  }

  Future<void> savePatroliData(List<Map<String, dynamic>> patroliData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('patroli_data', json.encode(patroliData));
  }

  Future<List<Map<String, dynamic>>> loadPatroliData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedData = prefs.getString('patroli_data');
    return savedData != null
        ? List<Map<String, dynamic>>.from(json.decode(savedData))
        : [];
  }

  Future<String> loadIdRiwayat() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('id_riwayat') ?? '';
  }

  Future<Map<String, dynamic>> initializeData(
      Function(int) onJumlahMasalahUpdate) async {
    try {
      String idRiwayat = await loadIdRiwayat();
      List<Map<String, dynamic>> savedData = await loadPatroliData();

      if (savedData.isEmpty) {
        savedData = await fetchPatroliData(idRiwayat);
        await savePatroliData(savedData);
      }

      int jumlahMasalah = await fetchJumlahMasalah(idRiwayat);
      onJumlahMasalahUpdate(jumlahMasalah);

      return {
        'idRiwayat': idRiwayat,
        'jumlahMasalah': jumlahMasalah,
        'patroliData': savedData,
      };
    } catch (e) {
      print('Error initializing data: $e');
      throw e;
    }
  }

  Future<void> refreshData(Function(List<Map<String, dynamic>>) updateUI,
      Function(int) updateJumlahMasalah) async {
    String idRiwayat = await loadIdRiwayat();
    List<Map<String, dynamic>> newData = await fetchPatroliData(idRiwayat);
    await savePatroliData(newData);
    updateUI(newData);

    int jumlahMasalah = await fetchJumlahMasalah(idRiwayat);
    updateJumlahMasalah(jumlahMasalah);
  }

  Future<void> showPatroliDalamModal(
      BuildContext context,
      Function(List<Map<String, dynamic>>) updateUI,
      Function(int) updateJumlahMasalah) async {
    final result = await showDialog(
      context: context,
      builder: (BuildContext context) => PatroliDalamModal(),
    );

    if (result == "submitted") {
      print("✅ Patroli berhasil disimpan, sekarang refresh datanya...");
      await refreshData(updateUI, updateJumlahMasalah);
    }
  }

  String formatWaktu(String? waktu) {
    if (waktu == null || waktu.isEmpty) return "-";
    try {
      final parsedTime = DateFormat("HH:mm:ss").parse(waktu);
      return DateFormat("HH:mm").format(parsedTime) + " WIB";
    } catch (e) {
      return "-";
    }
  }
}
