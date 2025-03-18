import 'package:flutter/material.dart';
import 'package:monitoring_guard_frontend/main.dart';
import 'package:monitoring_guard_frontend/tugas_selection/home_selection_form.dart';
import 'package:monitoring_guard_frontend/tugas_selection/home_selection_identitas.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class HomeSelectionScreen extends StatefulWidget {
  const HomeSelectionScreen({super.key});

  @override
  State<HomeSelectionScreen> createState() => _HomeSelectionScreenState();
}

class _HomeSelectionScreenState extends State<HomeSelectionScreen> {
  String idRiwayat = "";
  void updateIdRiwayat(String newId) {
    setState(() {
      idRiwayat = newId;
    });
  }

  Future<void> updateWaktuPatroli(String tipe) async {
    if (idRiwayat.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ID Riwayat tidak ditemukan')),
      );
      return;
    }

    final url =
        Uri.parse('${dotenv.env['BASE_URL']}/api/status/update-waktu-$tipe');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id_riwayat': idRiwayat}),
      );

      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['message'])),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MainNavigation(tipePatroli: tipe),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(responseData['message'] ?? 'Gagal memperbarui data')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD00000), // Warna merah di seluruh layar
      body: Stack(
        children: [
          // Latar belakang merah
          Container(
            width: double.infinity,
            height: double.infinity,
            color: const Color(0xFFD00000),
          ),

          // Identitas user di atas
          HomeSelectionIdentitas(
            onLogout: () {
              // Tambahkan logika logout di sini
            },
            onIdRiwayatLoaded: updateIdRiwayat,
          ),

          // Form pilihan patroli di bawah identitas
          Positioned(
            top: MediaQuery.of(context).size.height *
                0.36, // Turunkan agar tidak menimpa identitas
            left: 0,
            right: 0,
            child: HomeSelectionForm(
              onPatroliDalam: () {
                updateWaktuPatroli("dalam");
              },
              onPatroliLuar: () {
                updateWaktuPatroli("luar");
              },
            ),
          ),
        ],
      ),
    );
  }
}
