import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:monitoring_guard_frontend/history/history.dart';
import 'package:monitoring_guard_frontend/history/history_logic.dart'; // ✅ jangan lupa import

class HomeSelectionForm extends StatefulWidget {
  final VoidCallback onPatroliDalam;
  final VoidCallback onPatroliLuar;

  const HomeSelectionForm({
    super.key,
    required this.onPatroliDalam,
    required this.onPatroliLuar,
  });

  @override
  State<HomeSelectionForm> createState() => _HomeSelectionFormState();
}

class _HomeSelectionFormState extends State<HomeSelectionForm> {
  final HistoryLogic _historyLogic = HistoryLogic(); // ✅ dibuat sekali aja

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Pilih Patroli Anda",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 255, 255, 255),
            ),
          ),
          const SizedBox(height: 16),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildButton(
                icon: LucideIcons.home,
                label: "Patroli Dalam",
                onPressed: widget.onPatroliDalam,
              ),
              const SizedBox(height: 16),
              _buildButton(
                icon: LucideIcons.map,
                label: "Patroli Luar",
                onPressed: widget.onPatroliLuar,
              ),
              const SizedBox(height: 16),
              _buildButton(
                icon: LucideIcons.history,
                label: "Histori",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HistoryPage(
                          logic: _historyLogic), // ✅ kirim logic-nya
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 240,
      height: 70,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 30),
        label: Text(
          label,
          style: GoogleFonts.inter(fontSize: 20),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: Colors.black, width: 1),
          ),
          elevation: 4,
        ),
      ),
    );
  }
}
