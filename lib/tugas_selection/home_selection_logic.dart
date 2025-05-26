import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:monitoring_guard_frontend/main.dart';
import 'package:monitoring_guard_frontend/service/riwayat_dalam_helper.dart';
import 'package:monitoring_guard_frontend/service/riwayat_luar_helper.dart';
import 'package:monitoring_guard_frontend/widgets/anggotamodal.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeSelectionLogic {
  final BuildContext context;
  List<String> anggotaTerpakai = [];
  Map<String, String> semuaAnggota = {}; // id → nama

  HomeSelectionLogic(this.context);

  Future<void> loadIdRiwayat() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String idRiwayatStr = prefs.getString('id_riwayat') ?? "";
    debugPrint("ID Riwayat dari SharedPreferences: $idRiwayatStr");
  }

  Future<void> updateIdRiwayat(String newId, List<String> anggotaList) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (newId.isNotEmpty) {
      await prefs.setString('id_riwayat', newId);
    }

    // Ambil nama-nama anggota dari SharedPreferences
    String? nama1 = prefs.getString('anggota1');
    String? nama2 = prefs.getString('anggota2');
    String? id1 = prefs.getString('id_anggota_1');
    String? id2 = prefs.getString('id_anggota_2');

    if (id1 != null && nama1 != null) semuaAnggota[id1] = nama1;
    if (id2 != null && nama2 != null) semuaAnggota[id2] = nama2;

    debugPrint("ID Riwayat diupdate: $newId");
    debugPrint("Map Anggota: $semuaAnggota");
  }

  Future<void> tambahAnggotaTerpakai(
      String idAnggota, String namaAnggota) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('anggota_terpilih_id', idAnggota);
    await prefs.setString('anggota_terpilih_nama', namaAnggota);
    anggotaTerpakai.add(idAnggota);
  }

  Future<void> handlePatroli(String tipePatroli) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('tipe_patroli', tipePatroli);
    debugPrint("🟡 tipe_patroli disimpan: $tipePatroli");

    String? id1 = prefs.getString('id_anggota_1');
    String? id2 = prefs.getString('id_anggota_2');

    List<String> anggotaList = [id1, id2]
        .where((a) => a != null && a.isNotEmpty)
        .cast<String>()
        .toList();

    debugPrint("Anggota tersedia: $anggotaList");

    if (anggotaList.length == 1) {
      String anggota = anggotaList[0];
      String nama = semuaAnggota[anggota] ?? "Tidak diketahui";
      await tambahAnggotaTerpakai(anggota, nama);
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

    // Buat map id → nama untuk yang belum dipakai
    Map<String, String> anggotaMap = {
      for (var id in anggotaTersedia) id: semuaAnggota[id] ?? "Tidak diketahui"
    };

    AnggotaModalScreen.show(
      context,
      anggotaMap,
      (id, nama) async {
        await tambahAnggotaTerpakai(id, nama);
        await updateWaktuPatroli(tipePatroli, id);
      },
    );
  }

  Future<void> updateWaktuPatroli(String tipe, String idAnggota) async {
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
    debugPrint("id_anggota: $idAnggota");
    debugPrint("id_unit_kerja: $idUnitKerja");
    debugPrint("id_status: $idStatus");
    debugPrint("id_riwayat: $idRiwayat");

    final now = DateTime.now();
    final hari = DateFormat('EEEE', 'id_ID').format(now);
    final tanggal = DateFormat('yyyy-MM-dd').format(now);
    final jam = DateFormat('HH:mm:ss').format(now);

    if (tipe == "luar") {
      await RiwayatLuarHelper.insertRiwayatLuar({
        'id_unit': idUnit,
        'id_patroli': idPatroli,
        'id_anggota': idAnggota,
        'id_unit_kerja': idUnitKerja,
        'id_status_luar': idStatus,
        'hari': hari,
        'tanggal': tanggal,
        'waktu_mulai_luar': jam,
        'waktu_selesai_luar': '',
      });
    } else {
      await RiwayatDalamHelper.insertRiwayatDalam({
        'id_unit': idUnit,
        'id_patroli': idPatroli,
        'id_anggota': idAnggota,
        'id_unit_kerja': idUnitKerja,
        'id_status_dalam': idStatus,
        'hari': hari,
        'tanggal': tanggal,
        'waktu_mulai_dalam': jam,
        'waktu_selesai_dalam': '',
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text("Data berhasil disimpan di database lokal.")),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MainNavigation(tipePatroli: tipe),
      ),
    );
  }
}
