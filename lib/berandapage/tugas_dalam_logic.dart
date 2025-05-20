import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:monitoring_guard_frontend/service/db_helper.dart';
import 'package:monitoring_guard_frontend/service/detail_riwayat_dalam_helper.dart';
import 'package:monitoring_guard_frontend/widgets/patroli_dalam_modal.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TugasDalamLogic {
  Future<int> fetchJumlahMasalah(String idRiwayat) async {
    try {
      final id = int.tryParse(idRiwayat);
      if (id == null) {
        throw FormatException("idRiwayat bukan angka yang valid");
      }

      final List<Map<String, dynamic>> localData =
          await DetailRiwayatDalamHelper.getDetailRiwayatDalamById(id);
      return localData.length;
    } catch (e) {
      print('❌ Error hitung jumlah masalah lokal: $e');
      return 0;
    }
  }

  Future<List<Map<String, dynamic>>> fetchPatroliData(String idRiwayat) async {
    try {
      final id = int.tryParse(idRiwayat);
      if (id == null) {
        throw FormatException("idRiwayat bukan angka yang valid");
      }

      final List<Map<String, dynamic>> localData =
          await DetailRiwayatDalamHelper.getDetailRiwayatDalamById(id);
      return localData;
    } catch (e) {
      print('❌ Error ambil data patroli lokal: $e');
      return [];
    }
  }

  Future<void> savePatroliData(List<Map<String, dynamic>> patroliData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(
        'patroli_data', ''); // Optional: bisa dihapus kalau gak dipakai
  }

  Future<List<Map<String, dynamic>>> loadPatroliData() async {
    String idRiwayat = await loadIdRiwayat();
    return await fetchPatroliData(idRiwayat);
  }

  Future<String> loadIdRiwayat() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('id_riwayat') ?? '';
  }

  Future<Map<String, dynamic>> initializeData(
      Function(int) onJumlahMasalahUpdate) async {
    try {
      String idRiwayat = await loadIdRiwayat();
      List<Map<String, dynamic>> savedData = await fetchPatroliData(idRiwayat);
      int jumlahMasalah = savedData.length;
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
    updateUI(newData);

    int jumlahMasalah = newData.length;
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
      // Coba parsing jam:menit
      if (waktu.length == 5) {
        final parsedTime = DateFormat("HH:mm").parse(waktu);
        return DateFormat("HH:mm").format(parsedTime) + " WIB";
      }

      // Coba parsing jam:menit:detik
      final parsedTime = DateFormat("HH:mm:ss").parse(waktu);
      return DateFormat("HH:mm").format(parsedTime) + " WIB";
    } catch (e) {
      print("⚠️ Format waktu tidak dikenali: $waktu");
      return "-";
    }
  }
}
