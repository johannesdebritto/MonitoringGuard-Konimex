import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
  final Map<String, int> statusCache = {};
  bool _isFirstLoad = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isFirstLoad) {
      _isFirstLoad = false;
      _loadData();
    }
  }

  Future<void> _loadData() async {
    namaAnggota = await _logic.loadUserData();

    // ✅ Ambil data dari backend atau lokal via logic
    await _logic.fetchTugas();

    setState(() {
      tugasList = _logic.tugasList;
    });

    print("📦 Data tugasList di TugasScreen: $tugasList");

    // ✅ Cek ulang status semua tugas
    await _cekStatusSemuaTugas();

    if (mounted) setState(() {});
  }

  Future<void> _cekStatusSemuaTugas() async {
    if (tugasList.isEmpty) return;

    await Future.wait(
      tugasList.map((tugas) async {
        String idTugas = tugas['id_tugas'].toString();
        int? status = await _logic.cekStatusTugas(idTugas, force: true);
        if (status != null) {
          statusCache[idTugas] = status;
        }
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: tugasList.isEmpty
            ? ListView(
                children: const [
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text("Belum ada tugas."),
                    ),
                  ),
                ],
              )
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                itemCount: tugasList.length,
                itemBuilder: (context, index) =>
                    _buildTaskItem(tugasList[index]),
              ),
      ),
    );
  }

  Widget _buildTaskItem(Map tugas) {
    final idTugas = tugas['id_tugas'].toString();
    final idRiwayat = tugas['id_riwayat'].toString();
    final title = tugas['nama_tugas'] ?? 'Tugas';

    final status = statusCache[idTugas];
    final statusData = {
      0: {'text': 'Belum Selesai', 'color': const Color(0xFFFCA311)},
      2: {'text': 'Selesai', 'color': Colors.green.shade400},
      3: {'text': 'Ada Masalah', 'color': Colors.red.shade400},
    };

    final statusText =
        statusData[status]?['text'] as String? ?? 'Belum Selesai';
    final statusColor =
        statusData[status]?['color'] as Color? ?? const Color(0xFFFCA311);

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
              padding: const EdgeInsets.all(12),
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
                              "Status Tugas: ",
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
                              final data = await _logic.fetchRekap(idTugas);
                              if (data != null && data.isNotEmpty) {
                                final idStatus = data['id_status'];
                                statusCache[idTugas] = idStatus;
                                setState(() {});
                              }

                              if (!mounted) return;
                              showDialog(
                                context: context,
                                builder: (_) => CustomModalWidgets(
                                  namaTugas: title,
                                  namaAnggota: namaAnggota,
                                  idTugas: idTugas,
                                  idRiwayat: idRiwayat,
                                ),
                              );
                            } catch (e) {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Gagal memuat data: $e'),
                                ),
                              );
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
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Untuk dipanggil dari luar (misalnya dari KontenBeranda)
  void setInitialData({required List tugas, required String nama}) {
    tugasList = tugas;
    namaAnggota = nama;
    _cekStatusSemuaTugas();
  }
}
