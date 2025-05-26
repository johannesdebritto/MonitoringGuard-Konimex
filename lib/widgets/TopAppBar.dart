import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monitoring_guard_frontend/service/detail_riwayat_dalam_helper.dart';
import 'package:monitoring_guard_frontend/service/detail_riwayat_luar_helper.dart';
import 'package:monitoring_guard_frontend/widgets/connection_indicator.dart';
import 'package:monitoring_guard_frontend/widgets/kembalimodal.dart';
import 'package:monitoring_guard_frontend/tugas_selection/home_selection.dart';
import 'package:monitoring_guard_frontend/widgets/modal_submit_luar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TopBarScreen extends StatefulWidget {
  final String title;
  const TopBarScreen({super.key, required this.title});

  @override
  State<TopBarScreen> createState() => _TopBarScreenState();
}

class _TopBarScreenState extends State<TopBarScreen> {
  void _showExitConfirmation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? idRiwayat = prefs.getString('id_riwayat');
    String? tipePatroli = prefs.getString('tipe_patroli');

    debugPrint("🟡 tipe_patroli: $tipePatroli");

    // Pengecekan tipe patroli 'dalam' atau 'luar', biarkan selalu kembali ke HomeSelectionScreen
    // if (tipePatroli == "dalam") {
    //   await prefs.remove('patroli_data'); // ✅ Hapus data tipe dalam
    //   await prefs.remove('tipe_patroli'); // (Opsional) biar bersih sekalian

    //   Navigator.pushAndRemoveUntil(
    //     context,
    //     MaterialPageRoute(builder: (_) => const HomeSelectionScreen()),
    //     (route) => false,
    //   );
    //   return;
    // }

    // Modal hanya ditampilkan jika tipe patroli adalah luar (dihapus dulu)
    // showDialog(
    //   context: context,
    //   builder: (BuildContext context) {
    //     return KembaliModal(idRiwayat: idRiwayat ?? '');
    //   },
    // );

    if (tipePatroli == 'luar') {
      bool valid = await DetailRiwayatLuarHelper.isDetailRiwayatValid();
      if (valid) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeSelectionScreen()),
          (route) => false,
        );
      } else {
        showDialog(
          context: context,
          builder: (context) => const ModalSubmitScreen(),
        );
      }
    } else {
      // Default: langsung kembali ke HomeSelectionScreen
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeSelectionScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Judul Patroli
        Expanded(
          child: Text(
            widget.title,
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),

        // Indikator koneksi di tengah
        const Padding(
          padding: EdgeInsets.only(right: 12),
          child: ConnectionIndicator(type: IndicatorType.dalam),
        ),

        // Tombol keluar
        ElevatedButton.icon(
          onPressed: _showExitConfirmation,
          icon: SvgPicture.asset(
            'assets/berandaassets/logout.svg',
            width: 25,
            height: 25,
            color: Colors.white,
          ),
          label: Text(
            'Keluar',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFD00000),
            side: const BorderSide(color: Colors.white, width: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }
}
