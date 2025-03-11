import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monitoring_guard_frontend/widgets/custom_modal.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TugasScreen extends StatefulWidget {
  const TugasScreen({super.key});

  @override
  State<TugasScreen> createState() => _TugasScreenState();
}

class _TugasScreenState extends State<TugasScreen> {
  List tugasList = [];
  String namaAnggota = "";

  @override
  void initState() {
    super.initState();
    _loadUserData();
    fetchTugas();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(
        () => namaAnggota = prefs.getString('nama_anggota') ?? namaAnggota);
  }

  Future<void> fetchTugas() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? idUnit = prefs.getString('id_unit');
    if (idUnit == null) return;

    final response = await http
        .get(Uri.parse('${dotenv.env['BASE_URL']}/api/tugas/$idUnit'));
    if (response.statusCode == 200) {
      setState(() => tugasList = json.decode(response.body));
    } else {
      print("Gagal mengambil data tugas");
    }
  }

  Future<Map<String, dynamic>?> fetchRekap(String idTugas) async {
    final response = await http
        .get(Uri.parse('${dotenv.env['BASE_URL']}/api/tugas/rekap/$idTugas'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        itemCount: tugasList.length,
        itemBuilder: (context, index) => buildTaskItem(tugasList[index]),
      ),
    );
  }

  Widget buildTaskItem(Map tugas) {
    String title = tugas['nama_tugas'];
    String status = tugas['nama_status'];
    String idTugas = tugas['id_tugas'].toString();
    Color statusColor = status == "Selesai"
        ? Colors.green.shade400
        : status == "Belum Selesai"
            ? const Color(0xFFFCA311)
            : Colors.red.shade400;

    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          margin: const EdgeInsets.only(right: 8),
          decoration:
              const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
        ),
        Expanded(
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: Colors.blue.shade900),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade900)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text("Status: ",
                                style: GoogleFonts.inter(
                                    fontSize: 14, fontWeight: FontWeight.bold)),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 8),
                              decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8)),
                              child: Text(status,
                                  style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: statusColor)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    children: [
                      Text('Detail',
                          style: GoogleFonts.inter(
                              fontSize: 14, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Container(
                        decoration: BoxDecoration(
                            color: const Color(0xFF7F56D9),
                            borderRadius: BorderRadius.circular(10)),
                        child: IconButton(
                          onPressed: () async {
                            var rekapData = await fetchRekap(idTugas);
                            showDialog(
                              context: context,
                              builder: (context) => CustomModalWidgets(
                                status: status,
                                namaTugas: title,
                                namaAnggota: namaAnggota,
                                rekapData: rekapData,
                                idTugas: idTugas,
                              ),
                            );
                          },
                          icon: SvgPicture.asset(
                              'assets/berandaassets/search.svg',
                              width: 28,
                              height: 28),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
