import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class CustomModalWidgets extends StatefulWidget {
  final String status, namaAnggota1, namaTugas, idTugas;

  const CustomModalWidgets({
    super.key,
    required this.status,
    required this.namaAnggota1,
    required this.namaTugas,
    required this.idTugas,
    Map<String, dynamic>? rekapData,
  });

  @override
  _CustomModalWidgetsState createState() => _CustomModalWidgetsState();
}

class _CustomModalWidgetsState extends State<CustomModalWidgets> {
  late Color statusColor;
  String tanggalSelesai = '--', jamSelesai = '--';
  String tanggalGagal = '--', jamGagal = '--';
  List<String> masalahList = [];

  @override
  void initState() {
    super.initState();
    _setStatusData();
    _fetchRekapData();
  }

  void _setStatusData() {
    switch (widget.status) {
      case "Selesai":
        statusColor = const Color(0xFF38B000);
        break;
      case "Belum Selesai":
        statusColor = const Color(0xFFFCA311);
        break;
      default:
        statusColor = const Color(0xFFD00000);
    }
  }

  Future<void> _fetchRekapData() async {
    final response = await http.get(
      Uri.parse('${dotenv.env['BASE_URL']}/api/tugas/rekap/${widget.idTugas}'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        if (widget.status == "Selesai") {
          tanggalSelesai = _formatTanggal(data['tanggal_selesai']);
          jamSelesai = _formatJam(data['jam_selesai']);
        }

        if (widget.status == "Ada Masalah") {
          tanggalGagal = _formatTanggal(data['tanggal_gagal']);
          jamGagal = _formatJam(data['jam_gagal']);
          masalahList = data['keterangan_masalah'] != null
              ? [data['keterangan_masalah']]
              : [];
        }
      });
    }
  }

  String _formatTanggal(String? date) {
    if (date == null || date.isEmpty) return '--';
    try {
      DateTime parsedDate = DateTime.parse(date).toLocal();
      return DateFormat('dd-MM-yyyy').format(parsedDate);
    } catch (e) {
      return '--';
    }
  }

  String _formatJam(String? time) {
    if (time == null || time.isEmpty) return '--';
    try {
      DateTime parsedTime = DateTime.parse("1970-01-01T$time").toLocal();
      return DateFormat('HH:mm').format(parsedTime) + ' WIB';
    } catch (e) {
      return '--';
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
            _buildTextField('Nama Petugas', widget.namaAnggota1),
            _buildTextField('Tugas', widget.namaTugas),
            if (widget.status == "Selesai") ...[
              _buildTextField('Tanggal Selesai', tanggalSelesai),
              _buildTextField('Jam Selesai', jamSelesai),
            ],
            if (widget.status == "Ada Masalah") ...[
              _buildTextField('Tanggal Gagal', tanggalGagal),
              _buildTextField('Jam Gagal', jamGagal),
              _buildTextField('Keterangan Masalah', masalahList.join('\n')),
            ],
            _buildStatusField(),
            const SizedBox(height: 20),
            _buildCloseButton(),
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
          child: const Icon(Icons.info_outline, color: Colors.black54),
        ),
        const SizedBox(width: 8),
        Text('Detail Aktivitas',
            style:
                GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildTextField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          decoration: _boxDecoration(),
          child: Text(value,
              style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildStatusField() {
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
          child: Text(widget.status,
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
