import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monitoring_guard_frontend/widgets/custom_modal.dart';
import 'tugas_screen_logic.dart';

class TugasScreen extends StatefulWidget {
  const TugasScreen({super.key});

  @override
  State<TugasScreen> createState() => _TugasScreenState();
}

class _TugasScreenState extends State<TugasScreen> {
  final TugasScreenLogic _logic = TugasScreenLogic();
  List tugasList = [];
  String namaAnggota = "";
  Map<String, int> statusCache = {}; // Cache status tugas per id_tugas

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      namaAnggota = await _logic.loadUserData();
      tugasList = await _logic.fetchTugas();

      await _cekStatusSemuaTugas(); // Fetch status setelah dapat daftar tugas
      setState(() {}); // Update UI setelah semua selesai
    } catch (e) {
      print("❌ Error saat memuat data: $e");
    }
  }

  Future<void> _cekStatusSemuaTugas() async {
    if (tugasList.isEmpty) return;

    await Future.wait(tugasList.map((tugas) async {
      String idTugas = tugas['id_tugas'].toString();
      int? status = await _logic.cekStatusTugas(idTugas);
      if (status != null) {
        setState(() {
          statusCache[idTugas] = status;
        });
      }
    }));
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
    String idTugas = tugas['id_tugas'].toString();
    String idRiwayat = tugas['id_riwayat'].toString();
    int? status = statusCache[idTugas];

    final Map<int, Map<String, dynamic>> statusData = {
      0: {'text': 'Belum Selesai', 'color': const Color(0xFFFCA311)},
      2: {'text': 'Selesai', 'color': Colors.green.shade400},
      3: {'text': 'Ada Masalah', 'color': Colors.red.shade400},
    };

    final statusText = statusData[status]?['text'] ?? 'Belum Selesai';
    final statusColor = statusData[status]?['color'] ?? const Color(0xFFFCA311);

    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          margin: const EdgeInsets.only(right: 8),
          decoration: const BoxDecoration(
            color: Colors.black,
            shape: BoxShape.circle,
          ),
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
                        Text(
                          title,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              "Status: ",
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 8),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                statusText,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: statusColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    children: [
                      Text(
                        'Detail',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF7F56D9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: IconButton(
                          onPressed: () async {
                            try {
                              await _logic.fetchRekap(idTugas);
                              if (context.mounted) {
                                showDialog(
                                  context: context,
                                  builder: (context) => CustomModalWidgets(
                                    namaTugas: title,
                                    namaAnggota: namaAnggota,
                                    idTugas: idTugas,
                                    idRiwayat: idRiwayat,
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Gagal memuat data: $e'),
                                  ),
                                );
                              }
                            }
                          },
                          icon: SvgPicture.asset(
                            'assets/berandaassets/search.svg',
                            width: 28,
                            height: 28,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
