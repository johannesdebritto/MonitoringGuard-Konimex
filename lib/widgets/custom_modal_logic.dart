import 'dart:ui';

import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:monitoring_guard_frontend/service/detail_riwayat_luar_helper.dart';

class CustomModalLogic {
  final String idTugas;
  String idRiwayat = ""; // Ambil dari database, bukan SharedPreferences

  String status = "Belum Selesai";
  String tanggalSelesai = '--';
  String jamSelesai = '--';
  String tanggalGagal = '--';
  String jamGagal = '--';
  List<String> masalahList = [];

  CustomModalLogic({required this.idTugas, required String idRiwayat});

  Future<void> fetchRekapData() async {
    try {
      // Ambil status dan ID Riwayat dari DBHelper
      final idStatus =
          await DetailRiwayatLuarHelper.getStatusFromLatestRiwayat(idTugas);
      if (idStatus == null || idStatus == 0) {
        print("🚨 Status tidak ditemukan atau ID Status kosong");
        return;
      }

      // Ambil data rekap dari DB
      final data = await DetailRiwayatLuarHelper.getRiwayatDetails(
          idTugas); // Sesuaikan dengan method baru
      if (data == null) {
        print("⚠️ Data rekap tidak ditemukan");
        return;
      }
      // Mengomentari kode API karena tidak digunakan
      /*
      final url = Uri.parse(
          '${dotenv.env['BASE_URL']}/api/tugas/rekap/$idTugas/$idRiwayat');
      print("🔍 Fetching: $url");

      final response = await http.get(url);
      print("📡 Response dari API: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("✅ Data dari API: $data");

        if (data.isEmpty) {
          print("ℹ️ Tidak ada tugas yang ditemukan.");
          return;
        }

        if (data['id_status'].toString() == '2') {
          status = "Selesai";
          tanggalSelesai = _formatTanggal(data['tanggal_selesai']);
          jamSelesai = _formatJam(data['jam_selesai']);
        } else if (data['keterangan_masalah'] != null &&
            data['keterangan_masalah'].isNotEmpty) {
          status = "Ada Masalah";
          tanggalGagal = _formatTanggal(data['tanggal_gagal']);
          jamGagal = _formatJam(data['jam_gagal']);
          masalahList = [data['keterangan_masalah']];
        } else {
          status = "Belum Selesai";
        }
      } else {
        print(
            "ℹ️ Tidak ada tugas yang ditemukan (status: ${response.statusCode}).");
      }
      */
      // Cek status berdasarkan ID yang diambil dari DB
      if (idStatus == 2) {
        status = "Selesai";
        tanggalSelesai = _formatTanggal(data['tanggal_selesai']);
        jamSelesai = _formatJam(data['jam_selesai']);
        print("✅ Status: $status");
      } else if (idStatus == 1) {
        status = "Belum Selesai";
        print("🕒 Status: $status");
      } else if (data['keterangan_masalah'] != null &&
          data['keterangan_masalah'].toString().isNotEmpty) {
        status = "Ada Masalah";
        tanggalGagal = _formatTanggal(data['tanggal_gagal']);
        jamGagal = _formatJam(data['jam_gagal']);
        masalahList = [data['keterangan_masalah'] ?? ''];

        print("❗ Status: $status");
        print("📅 Tanggal Gagal: $tanggalGagal");
        print("⏰ Jam Gagal: $jamGagal");
        print("📝 Masalah: $masalahList");
      } else {
        status = "Ada Masalah";
        print("⚠️ Status default masalah");
      }
    } catch (e) {
      print("❌ ERROR fetching rekap data: $e");
    }
  }

  String _formatTanggal(String? date) {
    if (date == null || date.isEmpty || date == 'null') return '--';
    try {
      DateTime parsedDate = DateTime.parse(date).toLocal();
      return DateFormat('dd-MM-yyyy').format(parsedDate);
    } catch (e) {
      print("Error parsing tanggal: $e");
      return '--';
    }
  }

  String _formatJam(String? time) {
    if (time == null || time.isEmpty || time == 'null') return '--';
    try {
      return time.length == 5 ? "$time WIB" : "${time.substring(0, 5)} WIB";
    } catch (e) {
      print("Error parsing jam: $e");
      return '--';
    }
  }

  Color getStatusColor() {
    switch (status) {
      case "Selesai":
        return const Color(0xFF38B000);
      case "Belum Selesai":
        return const Color(0xFFFCA311);
      case "Ada Masalah":
        return const Color(0xFFD00000);
      default:
        return const Color(0xFF6C757D); // Warna default abu-abu
    }
  }
}
