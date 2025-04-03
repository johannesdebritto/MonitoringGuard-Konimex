import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monitoring_guard_frontend/berandapage/tugas.dart';
import 'package:monitoring_guard_frontend/berandapage/tugas_selesai.dart';
import 'package:monitoring_guard_frontend/berandapage/tugas_dalam.dart';
import 'package:monitoring_guard_frontend/widgets/modal_submit_dalam.dart';
import 'konten_beranda_logic.dart';

class KontenBeranda extends StatefulWidget {
  final String tipePatroli;
  const KontenBeranda({super.key, required this.tipePatroli});

  @override
  _KontenBerandaState createState() => _KontenBerandaState();
}

class _KontenBerandaState extends State<KontenBeranda> {
  final KontenBerandaLogic _logic = KontenBerandaLogic();

  @override
  void initState() {
    super.initState();
    _logic.fetchStatus();
    _logic.loadStatus();
    _logic.loadStatusDalam();
  }

  Future<void> _handleSubmit() async {
    try {
      if (widget.tipePatroli == "luar") {
        await _logic.submitTugas(context,
            showSnackbar: true); // Pastikan snackbar muncul
        await _logic.fetchStatus(); // Ambil ulang status dari backend
        if (mounted) setState(() {}); // Update UI setelah status berubah
      } else {
        await _logic.loadStatusDalam();
        final result = await showDialog<bool>(
          context: context,
          builder: (context) => ModalSubmitDalam(
            jumlahMasalah: _logic.jumlahMasalah,
            onSubmitSuccess: () =>
                Navigator.of(context, rootNavigator: true).pop(true),
          ),
        );
        if (result == true) {
          await _logic.submitTugas(context, showSnackbar: true);
          await _logic.fetchStatus(); // Ambil ulang status setelah submit
          if (mounted) setState(() => _logic.isSubmittedDalam = true);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Terjadi kesalahan, coba lagi nanti")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLuar = widget.tipePatroli == "luar";
    final isSubmitted = isLuar ? _logic.isSubmitted : _logic.isSubmittedDalam;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(35), topRight: Radius.circular(35)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.3),
                spreadRadius: 5,
                blurRadius: 10,
                offset: const Offset(0, -8))
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SvgPicture.asset('assets/berandaassets/tugas.svg',
                    width: 60, height: 60),
                const SizedBox(width: 1),
                Text('Tugas Hari Ini !',
                    style: GoogleFonts.inter(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                const Spacer(),
                isSubmitted
                    ? _statusBox("Selesai", Colors.green)
                    : _submitButton(),
              ],
            ),
            const SizedBox(height: 5),
            Expanded(
              child: isSubmitted
                  ? const TugasSelesaiScreen()
                  : isLuar
                      ? const TugasScreen()
                      : TugasDalamScreen(
                          onJumlahMasalahUpdate: _logic.updateJumlahMasalah),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusBox(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
        decoration: BoxDecoration(
            color: color, borderRadius: BorderRadius.circular(12)),
        child: Text(text,
            style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white)),
      );

  Widget _submitButton() => ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF7F56D9),
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: _handleSubmit,
        child: Text("Submit",
            style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white)),
      );
}
