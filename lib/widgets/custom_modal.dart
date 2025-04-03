import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'custom_modal_logic.dart';

class CustomModalWidgets extends StatefulWidget {
  final String namaAnggota, namaTugas, idTugas, idRiwayat;

  const CustomModalWidgets({
    super.key,
    required this.namaAnggota,
    required this.namaTugas,
    required this.idTugas,
    required this.idRiwayat,
  });

  @override
  _CustomModalWidgetsState createState() => _CustomModalWidgetsState();
}

class _CustomModalWidgetsState extends State<CustomModalWidgets> {
  late CustomModalLogic _logic;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _logic = CustomModalLogic(
      idTugas: widget.idTugas,
      idRiwayat: widget.idRiwayat.isNotEmpty
          ? widget.idRiwayat
          : '', // Pakai dulu kalau ada
    );
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      await _logic.fetchRekapData();
    } catch (e) {
      print("Error saat fetch data: $e");
      _hasError = true;
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? _buildLoading()
            : _hasError
                ? _buildError()
                : _buildDialog(),
      ),
    );
  }

  Widget _buildLoading() {
    return SizedBox(
      height: 100,
      child: Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildError() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(Icons.error, color: Colors.red, size: 50),
        SizedBox(height: 10),
        Text(
          'Gagal memuat data.',
          style: GoogleFonts.inter(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
        ),
        SizedBox(height: 10),
        _buildCloseButton(),
      ],
    );
  }

  Widget _buildDialog() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        _buildTextField('Nama Petugas', widget.namaAnggota),
        _buildTextField('Tugas', widget.namaTugas),
        if (_logic.status == "Selesai") ...[
          _buildTextField('Tanggal Selesai', _logic.tanggalSelesai),
          _buildTextField('Jam Selesai', _logic.jamSelesai),
        ],
        if (_logic.status == "Ada Masalah") ...[
          _buildTextField('Tanggal Gagal', _logic.tanggalGagal),
          _buildTextField('Jam Gagal', _logic.jamGagal),
          _buildTextField('Keterangan Masalah', _logic.masalahList.join('\n')),
        ],
        _buildStatusField(),
        const SizedBox(height: 20),
        _buildCloseButton(),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: _boxDecoration(),
          child: const Icon(Icons.info_outline, color: Colors.black54),
        ),
        const SizedBox(width: 8),
        Text('Detail Aktivitas',
            style:
                GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildTextField(String label, String? value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          decoration: _boxDecoration(),
          child: Text(value ?? '-',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildStatusField() {
    final statusColor = _logic.getStatusColor();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Status', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
              color: statusColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8)),
          alignment: Alignment.center,
          child: Text(_logic.status,
              style: GoogleFonts.inter(
                  color: statusColor, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildCloseButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF7F56D9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(vertical: 15),
      ),
      onPressed: () => Navigator.pop(context),
      child: Center(
        child: Text('Tutup',
            style: GoogleFonts.inter(color: Colors.white, fontSize: 16)),
      ),
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
