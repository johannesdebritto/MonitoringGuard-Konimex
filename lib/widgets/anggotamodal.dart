import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AnggotaModalScreen extends StatefulWidget {
  final List<String> anggotaTersedia;
  final Function(String) onAnggotaDipilih;

  const AnggotaModalScreen({
    super.key,
    required this.anggotaTersedia,
    required this.onAnggotaDipilih,
  });

  static void show(BuildContext context, List<String> anggotaTersedia,
      Function(String) onAnggotaDipilih) {
    showDialog(
      context: context,
      builder: (context) {
        return AnggotaModalScreen(
          anggotaTersedia: anggotaTersedia,
          onAnggotaDipilih: onAnggotaDipilih,
        );
      },
    );
  }

  @override
  State<AnggotaModalScreen> createState() => _AnggotaModalScreenState();
}

class _AnggotaModalScreenState extends State<AnggotaModalScreen> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      title: Text(
        "Pilih Anggota Patroli",
        textAlign: TextAlign.center,
        style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      content: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: IntrinsicWidth(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: widget.anggotaTersedia.map((anggota) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      textStyle: GoogleFonts.inter(fontSize: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () async {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      await prefs.setString('anggota_terpilih',
                          anggota); // Simpan anggota yang dipilih

                      widget.onAnggotaDipilih(anggota);
                      Navigator.pop(context);
                    },
                    child: Text(anggota,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter()),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
