import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lucide_icons/lucide_icons.dart';

typedef OnLogout = VoidCallback;

class HomeSelectionIdentitas extends StatefulWidget {
  final OnLogout onLogout;
  final Function(String, List<String>) onIdRiwayatLoaded; // Ubah tipe parameter

  const HomeSelectionIdentitas({
    super.key,
    required this.onLogout,
    required this.onIdRiwayatLoaded,
  });

  @override
  State<HomeSelectionIdentitas> createState() => _HomeSelectionIdentitasState();
}

class _HomeSelectionIdentitasState extends State<HomeSelectionIdentitas> {
  String namaUnit = "";
  String anggota1 = "";
  String anggota2 = "";
  String patroli = "";
  String unitKerja = "";
  String idRiwayat = "";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      namaUnit = prefs.getString('nama_unit') ?? "Unit Tidak Diketahui";
      anggota1 = prefs.getString('anggota1') ?? "";
      anggota2 = prefs.getString('anggota2') ?? "";
      idRiwayat = prefs.getString('id_riwayat') ?? "";
      patroli = prefs.getString('id_patroli') ?? "-";
      unitKerja = prefs.getString('id_unit_kerja') ?? "-";

      print("Patroli: $patroli, Unit Kerja: $unitKerja"); // Debugging

      List<String> anggotaList = [];
      if (anggota1.isNotEmpty) anggotaList.add(anggota1);
      if (anggota2.isNotEmpty) anggotaList.add(anggota2);

      widget.onIdRiwayatLoaded(idRiwayat, anggotaList);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 40, 20, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(30), // Sudut kiri bawah melengkung
            bottomRight: Radius.circular(30), // Sudut kanan bawah melengkung
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2), // Warna bayangan
              blurRadius: 5, // Efek blur shadow
              spreadRadius: 4, // Luas bayangan
              offset: const Offset(0, 7), // Bayangan ke bawah
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Selamat Bertugas di $namaUnit",
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            _buildInfoRow(LucideIcons.user, "Nama Anggota 1", anggota1),
            if (anggota2.isNotEmpty)
              _buildInfoRow(LucideIcons.user, "Nama Anggota 2", anggota2),
            _buildInfoRow(LucideIcons.shield, "Patroli", patroli),
            if (unitKerja.isNotEmpty)
              _buildInfoRow(LucideIcons.building, "Unit Kerja", unitKerja),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: ElevatedButton.icon(
                icon: Icon(LucideIcons.logOut, color: Colors.white),
                label: Text(
                  "Logout",
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: widget.onLogout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blueGrey),
          const SizedBox(width: 10),
          Text(
            "$label:",
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
