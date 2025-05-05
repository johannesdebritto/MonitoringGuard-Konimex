import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:monitoring_guard_frontend/main.dart';
import 'package:monitoring_guard_frontend/service/db_helper.dart';
import 'package:monitoring_guard_frontend/widgets/anggotamodal.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeSelectionLogic {
  final BuildContext context;
  List<String> anggotaTerpakai = [];
  List<String> semuaAnggota = [];

  HomeSelectionLogic(this.context);

  Future<void> loadIdRiwayat() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String idRiwayatStr = prefs.getString('id_riwayat') ?? "";
    debugPrint("ID Riwayat dari SharedPreferences: $idRiwayatStr");
  }

  Future<void> updateIdRiwayat(String newId, List<String> anggotaList) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Hanya update jika newId tidak kosong
    if (newId.isNotEmpty) {
      await prefs.setString('id_riwayat', newId);
    }
    semuaAnggota = anggotaList;
    debugPrint("ID Riwayat diupdate: $newId");
  }

  Future<void> tambahAnggotaTerpakai(String anggota) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('anggota_terpilih', anggota);
    anggotaTerpakai.add(anggota);
  }

  Future<void> handlePatroli(String tipePatroli) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString('tipe_patroli', tipePatroli);
    debugPrint("🟡 tipe_patroli disimpan: $tipePatroli");

    List<String> anggotaList = [
      prefs.getString('anggota1') ?? "",
      prefs.getString('anggota2') ?? ""
    ].where((a) => a.isNotEmpty).toList();

    debugPrint("Anggota tersedia: $anggotaList");

    if (anggotaList.length == 1) {
      String anggota = anggotaList[0];
      await prefs.setString('anggota_terpilih', anggota);
      await updateWaktuPatroli(tipePatroli, anggota);
      return;
    }

    final anggotaTersedia =
        anggotaList.where((a) => !anggotaTerpakai.contains(a)).toList();

    if (anggotaTersedia.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Semua anggota sudah melakukan patroli.")),
      );
      return;
    }

    AnggotaModalScreen.show(
      context,
      anggotaTersedia,
      (anggota) async {
        await prefs.setString('anggota_terpilih', anggota);
        await tambahAnggotaTerpakai(anggota);
        await updateWaktuPatroli(tipePatroli, anggota);
      },
    );
  }

  Future<void> updateWaktuPatroli(String tipe, String anggota) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String idUnit = prefs.getString('id_unit') ?? "";
    String idPatroli = prefs.getString('id_patroli') ?? "";
    String idUnitKerja = prefs.getString('id_unit_kerja') ?? "";
    String idStatus = tipe == "dalam"
        ? prefs.getString('id_status_dalam') ?? ""
        : prefs.getString('id_status_luar') ?? "";

    String idRiwayat = prefs.getString('id_riwayat') ?? "";

    debugPrint("Mengirim data ke database lokal:");
    debugPrint("id_unit: $idUnit");
    debugPrint("id_patroli: $idPatroli");
    debugPrint("id_anggota: $anggota");
    debugPrint("id_unit_kerja: $idUnitKerja");
    debugPrint("id_status: $idStatus");
    debugPrint("id_riwayat: $idRiwayat");

    if (tipe == "luar") {
      await DBHelper.insertRiwayatLuar({
        'id_unit': idUnit,
        'id_patroli': idPatroli,
        'id_anggota': anggota,
        'id_unit_kerja': idUnitKerja,
        'id_status_luar': idStatus,
        'hari': DateFormat('EEEE', 'id_ID').format(DateTime.now()),
        'tanggal': DateFormat('yyyy-MM-dd').format(DateTime.now()),
        'waktu_mulai_luar': DateFormat('HH:mm:ss').format(DateTime.now()),
        'waktu_selesai_luar': '', // kosong dulu kalau belum selesai
      });
    } else {
      await DBHelper.insertRiwayatDalam({
        'id_unit': idUnit,
        'id_patroli': idPatroli,
        'id_anggota': anggota,
        'id_unit_kerja': idUnitKerja,
        'id_status_dalam': idStatus,
        'hari': DateFormat('EEEE', 'id_ID').format(DateTime.now()),
        'tanggal': DateFormat('yyyy-MM-dd').format(DateTime.now()),
        'waktu_mulai_dalam': DateFormat('HH:mm:ss').format(DateTime.now()),
        'waktu_selesai_dalam': '', // kosong dulu kalau belum selesai
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text("Data berhasil disimpan di database lokal.")),
    );

    // Navigasi ke halaman berikutnya
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MainNavigation(tipePatroli: tipe),
      ),
    );
  }
}
