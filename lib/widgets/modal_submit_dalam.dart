import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:monitoring_guard_frontend/widgets/modal_submit_dalam_logic.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ModalSubmitDalam extends StatefulWidget {
  final int jumlahMasalah;
  final VoidCallback onSubmitSuccess;

  const ModalSubmitDalam({
    super.key,
    required this.jumlahMasalah,
    required this.onSubmitSuccess,
  });

  @override
  State<ModalSubmitDalam> createState() => _ModalSubmitDalamState();
}

class _ModalSubmitDalamState extends State<ModalSubmitDalam> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    String pesan = widget.jumlahMasalah == 0
        ? "Apakah Anda ingin mensubmit tugas ini tanpa keterangan masalah?"
        : "Anda akan mensubmit tugas ini dengan ${widget.jumlahMasalah} masalah. Yakin?";

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(LucideIcons.alertTriangle,
                    color: Colors.orange, size: 28),
                const SizedBox(width: 10),
                Text(
                  "Peringatan",
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),
            Text(
              pesan,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 12),
                        ),
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text(
                          "Batal",
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 12),
                        ),
                        onPressed: () async {
                          if (!mounted) return;
                          setState(() => _isLoading = true);

                          try {
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();

                            // Ambil data dari SharedPreferences
                            String? namaAnggota =
                                prefs.getString('nama_anggota');
                            String? bagian = prefs.getString('bagian');
                            String? idRiwayatString =
                                prefs.getString('id_riwayat');
                            int idRiwayat =
                                int.tryParse(idRiwayatString ?? '0') ?? 0;

                            // Debug: Log untuk mengecek nilai yang diambil
                            print("Nama Anggota: $namaAnggota");
                            print("Bagian: $bagian");
                            print("ID Riwayat: $idRiwayat");

                            final now = DateTime.now();
                            final tanggal = now.toIso8601String().split("T")[0];
                            final jam = now
                                .toIso8601String()
                                .split("T")[1]
                                .substring(0, 5);

                            // Debug: Log tanggal dan jam
                            print("Tanggal Selesai: $tanggal");
                            print("Jam Selesai: $jam");

                            Map<String, dynamic> localData = {
                              "nama_anggota": namaAnggota ?? "-",
                              "id_status": 2,
                              "bagian": bagian ?? "-",
                              "keterangan_masalah":
                                  widget.jumlahMasalah > 0 ? "Ada masalah" : "",
                              "tanggal_selesai": tanggal,
                              "jam_selesai": jam,
                              "id_riwayat": idRiwayat,
                            };

                            // Debug: Log localData
                            print("Local Data: $localData");

                            // Menggunakan submitData untuk menyimpan data ke lokal
                            await TugasService.submitData(
                              context: context,
                              onSubmitSuccess: () async {
                                print(
                                    "✅ Submit sukses, fetch ulang riwayat...");
                                await Future.delayed(
                                    const Duration(milliseconds: 500));
                                if (mounted) widget.onSubmitSuccess();
                                if (mounted) Navigator.of(context).pop(true);
                              },
                              localData: localData,
                            );
                          } catch (e) {
                            print("Error saat submit tugas: $e");
                          }

                          if (mounted) {
                            setState(() => _isLoading = false);
                          }
                        },
                        child: Text(
                          "Selesai",
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
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
