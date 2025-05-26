import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:monitoring_guard_frontend/service/riwayat_dalam_helper.dart'; // Untuk format waktu

class TugasService {
  static Future<void> submitData({
    required BuildContext context,
    required VoidCallback onSubmitSuccess,
    required Map<String, dynamic> localData,
  }) async {
    // Validasi: Pastikan bagian dan keterangan tidak kosong
    if (localData['bagian'] == null || localData['bagian'].isEmpty) {
      _showMessage(context, "🚨 Bagian tidak boleh kosong!", Colors.red);
      return;
    }
    if (localData['keterangan_masalah'] == null ||
        localData['keterangan_masalah'].isEmpty) {
      _showMessage(
          context, "🚨 Keterangan masalah tidak boleh kosong!", Colors.red);
      return;
    }

    // Ambil id_riwayat dari localData
    int? idRiwayat = localData['id_riwayat'];

    if (idRiwayat == null) {
      _showMessage(context, "🚨 ID Riwayat tidak valid!", Colors.red);
      return;
    }

    try {
      // Ambil data dari riwayat_dalam berdasarkan id_riwayat
      final data = await RiwayatDalamHelper.getRiwayatDalamById(idRiwayat);

      // Debugging: Menampilkan data yang diambil
      print("Data dari DBHelper: $data");

      if (data.isNotEmpty) {
        // Cek jika id_status_dalam atau waktu_selesai_dalam kosong
        if (data['id_status_dalam'] == null ||
            data['id_status_dalam'].toString().isEmpty ||
            data['waktu_selesai_dalam'] == null ||
            data['waktu_selesai_dalam'].toString().isEmpty) {
          Map<String, dynamic> updatedData = {
            'id_status_dalam':
                localData['id_status_dalam'] ?? "2", // Default jika kosong
            'waktu_selesai_dalam': localData['waktu_selesai_dalam'] ??
                DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now()),
          };

          print("Updating riwayat_dalam with data: $updatedData");

          // Update data di riwayat_dalam
          await RiwayatDalamHelper.updateRiwayatDalam(idRiwayat, updatedData);
          _showMessage(context, "✅ Tugas berhasil diperbarui!", Colors.green);
        } else {
          _showMessage(context, "⚠️ Data sudah lengkap, tidak perlu diupdate.",
              Colors.orange);
        }
      } else {
        _showMessage(context, "🚨 Data tidak ditemukan.", Colors.red);
        print("❌ Data tidak ditemukan.");
      }

      // Tetap jalankan alur sukses
      if (context.mounted) {
        Navigator.pop(context, true);
        Future.delayed(const Duration(milliseconds: 300), () {
          if (context.mounted) onSubmitSuccess();
        });
      }
    } catch (e) {
      _showMessage(context, "⚠️ Gagal menyimpan data", Colors.red);
      print("❌ Error saat menyimpan data: $e");
    }
  }

  static void _showMessage(BuildContext context, String message, Color color) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
