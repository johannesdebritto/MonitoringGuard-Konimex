import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:monitoring_guard_frontend/berandapage/tugas.dart';
import 'package:monitoring_guard_frontend/berandapage/tugas_selesai.dart';
import 'package:monitoring_guard_frontend/berandapage/tugas_dalam.dart'; // Import tugas dalam
import 'package:monitoring_guard_frontend/widgets/modal_submit.dart';

class KontenBeranda extends StatefulWidget {
  final String tipePatroli; // 🔥 Tambahkan tipePatroli

  const KontenBeranda({super.key, required this.tipePatroli});

  @override
  _KontenBerandaState createState() => _KontenBerandaState();
}

class _KontenBerandaState extends State<KontenBeranda> {
  bool _isSubmitted = false;

  @override
  void initState() {
    super.initState();
    _fetchStatus();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isSubmitted = prefs.getBool('isSubmitted') ?? false;
    });
  }

  Future<void> _fetchStatus() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? idUnit = prefs.getString('id_unit');

      if (idUnit == null) {
        print("🚨 ID Unit tidak ditemukan, coba login ulang?");
        return;
      }

      final response = await http.get(
          Uri.parse('${dotenv.env['BASE_URL']}/api/tugas/status_data/$idUnit'));

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        bool isCompleted = responseData["success"] == true;

        setState(() {
          _isSubmitted = isCompleted;
        });
      } else {
        print("🚨 Gagal mengambil status: ${response.body}");
      }
    } catch (e) {
      print("🚨 Error fetch status: $e");
    }
  }

  Future<void> _submitTugas() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? idRiwayat = prefs.getString('id_riwayat');

      if (idRiwayat == null) {
        print("🚨 ID Riwayat tidak ditemukan, mungkin login ulang?");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Terjadi kesalahan, coba login ulang")),
        );
        return;
      }

      final response = await http.post(
        Uri.parse('${dotenv.env['BASE_URL']}/api/submit'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"id_riwayat": idRiwayat}),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          _isSubmitted = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData["message"])),
        );
      } else {
        if (responseData["message"] == "Selesaikan tugas dulu sebelum submit") {
          showDialog(
            context: context,
            builder: (BuildContext context) => const ModalSubmitScreen(),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseData["message"])),
          );
        }
      }
    } catch (e) {
      print("🚨 Error submit: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal menghubungi server")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(35),
            topRight: Radius.circular(35),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              spreadRadius: 5,
              blurRadius: 10,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Row(
                  children: [
                    SvgPicture.asset(
                      'assets/berandaassets/tugas.svg',
                      width: 60,
                      height: 60,
                    ),
                    const SizedBox(width: 1),
                    Text(
                      'Tugas Hari Ini !',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      softWrap: true,
                    ),
                  ],
                ),
                const Spacer(),
                _isSubmitted
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "Selesai",
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7F56D9),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _submitTugas,
                        child: Text(
                          "Submit",
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
              ],
            ),
            const SizedBox(height: 5),
            Expanded(
              child: _isSubmitted
                  ? const TugasSelesaiScreen() // 🔥 Tampilannya sama, selesai
                  : (widget.tipePatroli == "luar"
                      ? const TugasScreen() // 🔥 Jika patroli luar
                      : const TugasDalamScreen()), // 🔥 Jika patroli dalam
            ),
          ],
        ),
      ),
    );
  }
}
