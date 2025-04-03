import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:monitoring_guard_frontend/riwayatpage/daftar_riwayat_luar_logic.dart';
import 'package:monitoring_guard_frontend/riwayatpage/daftar_riwayat_dalam.dart';

class RiwayatKontenScreen extends StatefulWidget {
  final String tipePatroli;

  const RiwayatKontenScreen({super.key, required this.tipePatroli});

  @override
  State<RiwayatKontenScreen> createState() => _RiwayatKontenScreenState();
}

class _RiwayatKontenScreenState extends State<RiwayatKontenScreen> {
  String? _idRiwayat;

  @override
  void initState() {
    super.initState();
    _loadIdRiwayat();
  }

  Future<void> _loadIdRiwayat() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _idRiwayat = prefs.getString('id_riwayat');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.75,
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
                Expanded(
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        'assets/berandaassets/tugas.svg',
                        width: 60,
                        height: 60,
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          'Riwayat Tugas\nMinggu Ini!',
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          softWrap: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Expanded(
              child: widget.tipePatroli == "luar"
                  ? const DaftarRiwayatScreen()
                  : _idRiwayat == null
                      ? const Center(child: CircularProgressIndicator())
                      : DetailRiwayatDalam(),
            ),
          ],
        ),
      ),
    );
  }
}
