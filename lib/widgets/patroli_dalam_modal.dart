import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PatroliDalamModal extends StatefulWidget {
  @override
  _PatroliDalamModalState createState() => _PatroliDalamModalState();
}

class _PatroliDalamModalState extends State<PatroliDalamModal> {
  final TextEditingController _bagianController = TextEditingController();
  final TextEditingController _keteranganController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submitPatroliDalam() async {
    setState(() {
      _isLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? namaAnggota = prefs.getString('anggota_terpilih');

    // Cek apakah id_riwayat disimpan sebagai String atau Int
    String? idRiwayatString = prefs.getString('id_riwayat');
    int? idRiwayat = idRiwayatString != null
        ? int.tryParse(idRiwayatString)
        : prefs.getInt('id_riwayat');

    if (namaAnggota == null || idRiwayat == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Anggota atau ID Riwayat belum dipilih")),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    String bagian = _bagianController.text.trim();
    String keterangan = _keteranganController.text.trim();

    if (bagian.isEmpty || keterangan.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Bagian dan keterangan tidak boleh kosong")),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final url = Uri.parse(
        '${dotenv.env['BASE_URL']}/api/tugas_dalam/submit-patroli-dalam');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "id_riwayat": idRiwayat,
        "nama_anggota": namaAnggota,
        "id_status": 1,
        "bagian": bagian,
        "keterangan_masalah": keterangan,
      }),
    );

    if (response.statusCode == 200) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Patroli dalam berhasil disimpan")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Gagal menyimpan patroli dalam: ${response.body}")),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Tambah Patroli Dalam"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _bagianController,
            decoration: const InputDecoration(labelText: "Bagian"),
          ),
          TextField(
            controller: _keteranganController,
            decoration: const InputDecoration(labelText: "Keterangan Masalah"),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Batal"),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submitPatroliDalam,
          child: _isLoading
              ? const CircularProgressIndicator()
              : const Text("Simpan"),
        ),
      ],
    );
  }
}
