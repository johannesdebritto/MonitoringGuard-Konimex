import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'tugas_dalam_logic.dart';

class TugasDalamScreen extends StatefulWidget {
  final Function(int) onJumlahMasalahUpdate;

  const TugasDalamScreen({super.key, required this.onJumlahMasalahUpdate});

  @override
  State<TugasDalamScreen> createState() => _TugasDalamScreenState();
}

class _TugasDalamScreenState extends State<TugasDalamScreen> {
  List<Map<String, dynamic>> _patroliData = [];
  int _jumlahMasalah = 0;
  bool _isLoading = true;
  bool _isError = false;
  late String idRiwayat;
  final TugasDalamLogic logic = TugasDalamLogic();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _updateJumlahMasalah(int newJumlah) {
    setState(() {
      _jumlahMasalah = newJumlah; // Perbaikan nama variabel
    });
  }

  void _updatePatroliData(List<Map<String, dynamic>> newData) {
    setState(() {
      _patroliData = newData;
    });
  }

  // Fungsi untuk memuat data
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _isError = false;
    });

    try {
      final data = await logic.initializeData(_updateJumlahMasalah);
      setState(() {
        idRiwayat = data['idRiwayat'];
        _jumlahMasalah = data['jumlahMasalah'];
        _patroliData = data['patroliData'];
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() {
        _isLoading = false;
        _isError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 20,
            left: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ElevatedButton.icon(
                  onPressed: () => logic.showPatroliDalamModal(
                    context,
                    _updatePatroliData,
                    _updateJumlahMasalah, // Pastikan ini ada di StatefulWidget
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE65100),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: Text(
                    'Keterangan Masalah',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Total Masalah: $_jumlahMasalah",
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          Positioned.fill(
            top: 75,
            bottom: 48,
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _isError
                    ? const Center(child: Text("Terjadi kesalahan, coba lagi"))
                    : _patroliData.isEmpty
                        ? const Center(
                            child: Text("Belum ada masalah yang tercatat"))
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _patroliData.length,
                            itemBuilder: (context, index) {
                              final data = _patroliData[index];
                              return _buildPatroliCard(data);
                            },
                          ),
          ),
        ],
      ),
    );
  }

  // Widget untuk membuat card patroli
  Widget _buildPatroliCard(Map<String, dynamic> data) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.black, width: 1.5),
      ),
      elevation: 5,
      shadowColor: Colors.black54,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.business, color: Colors.black54),
                const SizedBox(width: 8),
                Text(
                  "Bagian: ${data['bagian'] ?? '-'}",
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const Divider(thickness: 1, color: Colors.black45),
            const SizedBox(height: 5),
            Row(
              children: [
                const Icon(Icons.report_problem, color: Colors.redAccent),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Keterangan: ${data['keterangan_masalah'] ?? '-'}",
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.access_time, color: Colors.black54),
                const SizedBox(width: 8),
                Text(
                  "Waktu: ${logic.formatWaktu(data['jam_selesai'])}",
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
