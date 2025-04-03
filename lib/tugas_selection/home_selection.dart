import 'package:flutter/material.dart';
import 'package:monitoring_guard_frontend/main.dart';
import 'package:monitoring_guard_frontend/tugas_selection/home_selection_form.dart';
import 'package:monitoring_guard_frontend/tugas_selection/home_selection_identitas.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:monitoring_guard_frontend/widgets/anggotamodal.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeSelectionScreen extends StatefulWidget {
  const HomeSelectionScreen({super.key});

  @override
  State<HomeSelectionScreen> createState() => _HomeSelectionScreenState();
}

class _HomeSelectionScreenState extends State<HomeSelectionScreen> {
  List<String> anggotaTerpakai = [];
  List<String> semuaAnggota = [];

  @override
  void initState() {
    super.initState();
    loadIdRiwayat();
  }

  Future<void> loadIdRiwayat() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String idRiwayat = prefs.getString('id_riwayat') ?? "";
    debugPrint("ID Riwayat dari SharedPreferences: $idRiwayat");
  }

  void updateIdRiwayat(String newId, List<String> anggotaList) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('id_riwayat', newId);
    setState(() {
      semuaAnggota = anggotaList;
    });
  }

  void tambahAnggotaTerpakai(String anggota) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('anggota_terpilih', anggota);
    setState(() {
      anggotaTerpakai.add(anggota);
    });
  }

  void handlePatroli(String tipePatroli) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> anggotaList = [
      prefs.getString('anggota1') ?? "",
      prefs.getString('anggota2') ?? ""
    ].where((a) => a.isNotEmpty).toList();

    debugPrint("Anggota tersedia: $anggotaList");

    if (anggotaList.length == 1) {
      String anggota = anggotaList[0];
      await prefs.setString('anggota_terpilih', anggota);
      updateWaktuPatroli(tipePatroli, anggota);
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
        tambahAnggotaTerpakai(anggota);
        updateWaktuPatroli(tipePatroli, anggota);
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

    debugPrint("Mengirim data ke backend:");
    debugPrint("id_unit: $idUnit");
    debugPrint("id_patroli: $idPatroli");
    debugPrint("id_anggota: $anggota");
    debugPrint("id_unit_kerja: $idUnitKerja");
    debugPrint("id_status: $idStatus");

    final url =
        Uri.parse('${dotenv.env['BASE_URL']}/api/status/update-waktu-$tipe');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id_unit': idUnit,
          'id_patroli': idPatroli,
          'id_anggota': anggota,
          'id_unit_kerja': idUnitKerja,
          'id_status': idStatus,
        }),
      );

      debugPrint("Response status: ${response.statusCode}");
      debugPrint("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        /// 🔥 Simpan id_riwayat sebagai String di SharedPreferences
        int newIdRiwayat = responseData['id_riwayat'] ?? 0;
        await prefs.setString('id_riwayat', newIdRiwayat.toString());

        debugPrint("ID Riwayat terbaru disimpan: $newIdRiwayat");

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Waktu patroli berhasil diperbarui.")),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MainNavigation(tipePatroli: tipe),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text("Gagal memperbarui waktu patroli: ${response.body}")),
        );
      }
    } catch (e) {
      debugPrint('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Terjadi kesalahan, coba lagi.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD00000),
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            color: const Color(0xFFD00000),
          ),
          HomeSelectionIdentitas(
            onLogout: () {},
            onIdRiwayatLoaded: (id, anggotaList) {
              updateIdRiwayat(id, anggotaList);
            },
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.36,
            left: 0,
            right: 0,
            child: HomeSelectionForm(
              onPatroliDalam: () => handlePatroli("dalam"),
              onPatroliLuar: () => handlePatroli("luar"),
            ),
          ),
        ],
      ),
    );
  }
}
