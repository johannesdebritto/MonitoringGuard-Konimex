import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

class LogoutModal extends StatefulWidget {
  final VoidCallback onLogout;

  const LogoutModal({super.key, required this.onLogout});

  @override
  State<LogoutModal> createState() => _LogoutModalState();
}

class _LogoutModalState extends State<LogoutModal> {
  bool isLoading = false;

  Future<void> _handleLogout() async {
    setState(() => isLoading = true);

    try {
      final url = Uri.parse('${dotenv.env['BASE_URL']}/api/sync');

      // TODO: Ganti dengan data sync asli dari helper
      final dataToSync = [];

      print("📤 [NAGA SYNC] Mengirim data: $dataToSync");

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(dataToSync),
      );

      if (response.statusCode == 200) {
        print("🐉 [NAGA SYNC] Data berhasil disinkronkan.");
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        widget.onLogout();
      } else {
        print("🦇 [NAGA SYNC] Gagal sync. Status: ${response.statusCode}");
        print("📦 [NAGA SYNC] Response body: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("🦇 Gagal sinkronisasi sebelum logout")),
        );
      }
    } catch (e) {
      print("🧨 [NAGA SYNC] Exception saat logout: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("🧨 Error saat sync data")),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: isLoading
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 10),
                    Text(
                      "Sedang logout dan sinkronisasi data...",
                      style: GoogleFonts.inter(fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ],
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Apakah Anda yakin ingin logout?",
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            "Batal",
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                        ),
                        TextButton(
                          onPressed: _handleLogout,
                          child: Text(
                            "Ya",
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
