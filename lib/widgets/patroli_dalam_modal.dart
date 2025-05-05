import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'patroli_dalam_logic.dart';

class PatroliDalamModal extends StatefulWidget {
  @override
  _PatroliDalamModalState createState() => _PatroliDalamModalState();
}

class _PatroliDalamModalState extends State<PatroliDalamModal> {
  final TextEditingController _bagianController = TextEditingController();
  final TextEditingController _keteranganController = TextEditingController();
  bool _isLoading = false;
  final PatroliDalamLogic _logic = PatroliDalamLogic();

  Future<void> _submitPatroliDalam() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _logic.submitPatroliDalam(
        context,
        _bagianController.text.trim(),
        _keteranganController.text.trim(),
      );

      if (result) {
        Navigator.pop(context, "submitted");
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildTextField('Bagian', _bagianController),
            const SizedBox(height: 10),
            _buildTextField('Keterangan Masalah', _keteranganController),
            const SizedBox(height: 20),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: _boxDecoration(),
          child: const Icon(Icons.add_task, color: Colors.black54),
        ),
        const SizedBox(width: 8),
        Text('Tambah Patroli Dalam',
            style:
                GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Container(
          decoration: _boxDecoration(),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
              border: InputBorder.none,
              hintText: 'Masukkan $label',
              hintStyle: GoogleFonts.inter(fontWeight: FontWeight.w500),
            ),
            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
Expanded(
  child: ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.red, // warna latar tombol
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(vertical: 15),
    ),
    onPressed: () => Navigator.pop(context),
    child: Text(
      'Batal',
      style: GoogleFonts.inter(
        color: Colors.white, // warna teks putih
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
),

        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7F56D9),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
            onPressed: _isLoading ? null : _submitPatroliDalam,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text('Simpan',
                    style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }

  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      border: Border.all(color: Colors.grey.shade400),
      borderRadius: BorderRadius.circular(8),
      color: Colors.white,
      boxShadow: [
        BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(2, 2))
      ],
    );
  }
}
