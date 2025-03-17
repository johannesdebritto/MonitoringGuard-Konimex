import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monitoring_guard_frontend/authenticationpage/login_modal_patroli.dart';

class UnitPatroliForm extends StatefulWidget {
  final String unitAnggota;
  final String patroliAnggota;
  final Function(String) onUnitAnggotaChanged;
  final Function(String) onPatroliAnggotaChanged;

  const UnitPatroliForm({
    super.key,
    required this.unitAnggota,
    required this.patroliAnggota,
    required this.onUnitAnggotaChanged,
    required this.onPatroliAnggotaChanged,
  });

  @override
  State<UnitPatroliForm> createState() => _UnitPatroliFormState();
}

class _UnitPatroliFormState extends State<UnitPatroliForm> {
  Widget _buildLabel(String text) => Text(
        text,
        style: GoogleFonts.robotoSlab(fontSize: 16, color: Colors.white),
      );

  Widget _buildTextField(BuildContext context, String value, String label,
      String fieldType, Function(String) onChanged) {
    return GestureDetector(
      onTap: () async {
        final result = await showDialog<String>(
          context: context,
          barrierDismissible: true,
          builder: (context) =>
              LoginModalUnitPatroli(initialValue: value, fieldType: fieldType),
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
        _buildLabel("Unit Anggota"),
        _buildTextField(context, widget.unitAnggota, "Masukkan Unit Anggota",
            "unit_anggota", widget.onUnitAnggotaChanged),
        const SizedBox(height: 15),
        _buildLabel("Patroli Anggota"),
        _buildTextField(
            context,
            widget.patroliAnggota,
            "Masukkan Patroli Anggota",
            "patroli_anggota",
            widget.onPatroliAnggotaChanged),
      ],
    );
  }
}
