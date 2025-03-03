import 'package:flutter/material.dart';
import 'package:monitoring_guard_frontend/main.dart';
import 'package:monitoring_guard_frontend/widgets/modal_nfc.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';

class NFCScannerScreen extends StatefulWidget {
  const NFCScannerScreen({super.key});

  @override
  State<NFCScannerScreen> createState() => _NFCScannerScreenState();
}

class _NFCScannerScreenState extends State<NFCScannerScreen> {
  ValueNotifier<dynamic> result = ValueNotifier(null);
  bool isScanning = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(15),
            bottomRight: Radius.circular(15),
          ),
          child: AppBar(
            automaticallyImplyLeading: false, // Menghapus tombol kembali
            title: const Text(
              'Scan RFID !',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            backgroundColor:
                const Color(0xFFD00000), // Warna merah yang diminta
            centerTitle: true,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Iconsax.wifi_outline, size: 80, color: Colors.blueAccent),
            SizedBox(height: 16),
            Text(
              'Dekatkan HP ke tag RFID',
              style:
                  GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: isScanning ? null : _tagRead,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: isScanning
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text('Mulai Scan', style: GoogleFonts.inter(fontSize: 16)),
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ValueListenableBuilder<dynamic>(
                valueListenable: result,
                builder: (context, value, _) => Text(
                  'Hasil Scan: ${value ?? "Belum ada data"}',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                      fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Tombol "Aman"
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return const NFCModalScreen(status: "aman");
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Aman',
                    style: GoogleFonts.inter(fontSize: 16, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 16),

                // Tombol "Ada Masalah"
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return const NFCModalScreen(status: "masalah");
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Ada Masalah',
                    style: GoogleFonts.inter(fontSize: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: isScanning
                  ? null
                  : () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const MainNavigation(), // Arahkan ke MainNavigation
                        ),
                      );
                    },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: isScanning
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text('Kembali', style: GoogleFonts.inter(fontSize: 16)),
            )
          ],
        ),
      ),
    );
  }

  void _tagRead() {
    setState(() => isScanning = true);
    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      result.value = tag.data;
      NfcManager.instance.stopSession();
      setState(() => isScanning = false);
    });
  }
}
