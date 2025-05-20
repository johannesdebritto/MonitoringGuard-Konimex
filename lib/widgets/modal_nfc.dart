import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:monitoring_guard_frontend/service/db_helper.dart';
import 'package:monitoring_guard_frontend/service/detail_riwayat_luar_helper.dart';
import 'package:monitoring_guard_frontend/service/init_db.dart';
import 'package:monitoring_guard_frontend/service/riwayat_luar_helper.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class NFCModalScreen extends StatefulWidget {
  final String status;
  final String idTugas;
  final VoidCallback onConfirm;

  const NFCModalScreen({
    super.key,
    required this.status,
    required this.idTugas,
    required this.onConfirm,
  });

  @override
  State<NFCModalScreen> createState() => _NFCModalScreenState();
}

class _NFCModalScreenState extends State<NFCModalScreen> {
  final TextEditingController _keteranganController = TextEditingController();
  bool isLoading = false;
  String namaAnggota = "";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      namaAnggota = prefs.getString('anggota_terpilih') ??
          prefs.getString('anggota1') ??
          "Anggota Tidak Diketahui";
    });
  }

  Future<void> updateStatus() async {
    if (namaAnggota.isEmpty) {
      showError("Nama anggota tidak ditemukan! Harap login ulang.");
      return;
    }

    setState(() => isLoading = true);

    final isMasalah = widget.status == "masalah";

    // Komentari bagian ini untuk offline
    // final baseUrl = dotenv.env['BASE_URL'];
    // final rekapUrl = isMasalah
    //     ? '$baseUrl/api/tugas/rekap-tidak-aman/${widget.idTugas}'
    //     : '$baseUrl/api/tugas/rekap-selesai/${widget.idTugas}';

    final body = jsonEncode({
      "id_status": isMasalah ? 3 : 2,
      "waktu": DateTime.now().toIso8601String(),
      "nama_anggota": namaAnggota,
      "id_riwayat": widget.idTugas,
      if (isMasalah) "keterangan": _keteranganController.text,
    });

    try {
      // Offline version with dbHelper
      final db = await InitDb.getDatabase();

      final idStatus = isMasalah ? 3 : 2;
      final tanggal = DateTime.now().toIso8601String();
      final jam = TimeOfDay.now().format(context);

      // Fetch id_unit jika memang dibutuhkan
      final idUnit = await RiwayatLuarHelper.getIdUnit();

      // Menyiapkan data untuk insert ke tabel `detail_riwayat_luar`
      final dataToInsert = {
        'id_tugas': widget.idTugas,
        'id_status': idStatus,
        'tanggal_selesai': tanggal,
        'jam_selesai': jam,
        'id_anggota': namaAnggota,
        'id_unit': idUnit,
      };

      // Jika status "masalah", tambahkan keterangan, tanggal gagal, dan waktu gagal
      if (isMasalah) {
        dataToInsert['keterangan_masalah'] = _keteranganController.text;
        dataToInsert['tanggal_gagal'] =
            tanggal; // Gunakan tanggal sekarang untuk tanggal gagal
        dataToInsert['jam_gagal'] =
            jam; // Gunakan jam sekarang untuk waktu gagal
      }

      // Insert ke `detail_riwayat_luar` dengan data yang telah disiapkan
      await DetailRiwayatLuarHelper.insertDetailRiwayatLuar(dataToInsert);

      // Uncomment the below block for online request when ready to use it
      /*
    final response = await http.put(
      Uri.parse(rekapUrl),
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      widget.onConfirm();
      if (mounted) Navigator.of(context).pop();
    } else {
      showError("Gagal memperbarui rekap: ${response.body}");
    }
    */

      widget.onConfirm();
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      showError("Terjadi kesalahan: $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMasalah = widget.status == "masalah";

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              isMasalah
                  ? 'assets/widgetsassets/danger.svg'
                  : 'assets/widgetsassets/centang.svg',
              width: 80,
              height: 80,
            ),
            const SizedBox(height: 16),
            Text(
              isMasalah ? "Lokasi Terdapat Masalah" : "Lokasi Aman",
              style:
                  GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              isMasalah
                  ? "Segera Tuliskan Keterangan Masalah!"
                  : "Terima Kasih Sudah Bertugas!",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 14, color: Colors.grey),
            ),
            if (isMasalah) ...[
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Text("Keterangan Masalah",
                    style: GoogleFonts.inter(
                        fontSize: 14, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _keteranganController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "Tulis keterangan masalah...",
                  hintStyle: GoogleFonts.inter(color: Colors.grey),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : updateStatus,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7F56D9),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text("Konfirmasi",
                        style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
