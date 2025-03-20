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
  String idRiwayat = "";
  int jumlahAnggota = 0;
  List<String> anggotaTerpakai = [];
  List<String> semuaAnggota = [];

  void updateIdRiwayat(String newId, List<String> anggotaList) {
    setState(() {
      idRiwayat = newId;
      semuaAnggota = anggotaList;
      jumlahAnggota = anggotaList.length;
    });
  }

  void tambahAnggotaTerpakai(String anggota) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'anggota_terpilih', anggota); // Simpan nama anggota yang dipilih

    setState(() {
      anggotaTerpakai.add(anggota);
    });
  }

  void handlePatroli(String tipePatroli) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> anggotaList = [
      prefs.getString('anggota1') ?? "",
      prefs.getString('anggota2') ?? ""
    ].where((a) => a.isNotEmpty).toList(); // Filter hanya yang tidak kosong

    if (anggotaList.length == 1) {
      // Langsung update tanpa modal
      String anggota = anggotaList[0];
      await prefs.setString('anggota_terpilih', anggota);
      updateWaktuPatroli(tipePatroli, anggota);
      return;
    }

    // Kalau ada 2 anggota, munculkan modal untuk memilih
    final anggotaTersedia =
        anggotaList.where((a) => !anggotaTerpakai.contains(a)).toList();

    if (anggotaTersedia.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Semua anggota sudah melakukan patroli.")),
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
    if (idRiwayat.isEmpty) return;

    final url =
        Uri.parse('${dotenv.env['BASE_URL']}/api/status/update-waktu-$tipe');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id_riwayat': idRiwayat, 'anggota': anggota}),
      );

      if (response.statusCode == 200) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MainNavigation(tipePatroli: tipe),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error: $e');
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
