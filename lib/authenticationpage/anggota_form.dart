import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monitoring_guard_frontend/authenticationpage/login_modal_anggota.dart';

class AnggotaForm extends StatelessWidget {
  final String pegawai;
  final String anggota2;
  final Function(String) onPegawaiChanged;
  final Function(String) onAnggota2Changed;

  const AnggotaForm({
    super.key,
    required this.pegawai,
    required this.anggota2,
    required this.onPegawaiChanged,
    required this.onAnggota2Changed,
  });

  Widget _buildLabel(String text) => Text(
        text,
        style: GoogleFonts.robotoSlab(fontSize: 16, color: Colors.white),
      );

  Widget _buildTextField(BuildContext context, String value, String label,
      String anggotaType, Function(String) onChanged) {
    return GestureDetector(
      onTap: () async {
        final result = await showDialog<String>(
          context: context,
          barrierDismissible: true,
          builder: (context) => LoginModalAnggota(
            initialValue: value,
            anggotaType: anggotaType,
          ),
        );
        if (result != null) {
          onChanged(result);
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black, width: 2),
        ),
        child: Text(
          value.isEmpty ? label : value,
          style: GoogleFonts.robotoSlab(
              fontSize: 16, color: value.isEmpty ? Colors.grey : Colors.black),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel("Nama Anggota 1"),
        _buildTextField(context, pegawai, "Masukkan Nama Anggota", "Anggota 1",
            onPegawaiChanged), // Nama sesuai modal
        const SizedBox(height: 15),
        _buildLabel("Nama Anggota 2"),
        _buildTextField(context, anggota2, "Masukkan Nama Anggota 2",
            "Anggota 2", onAnggota2Changed), // Nama sesuai modal
      ],
    );
  }
}
