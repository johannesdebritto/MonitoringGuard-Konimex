import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

class WarningModalScreen extends StatelessWidget {
  final List<String> errors;
  final Color color; // Tambahkan parameter warna

  const WarningModalScreen({
    super.key,
    required this.errors,
    required this.color, // Pastikan warna harus diisi
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.alertTriangle,
              size: 50,
              color: color, // Gunakan warna sesuai parameter
            ),
            const SizedBox(height: 10),
            Text(
              "Peringatan",
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: color, // Gunakan warna sesuai parameter
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Divider(color: Colors.grey.shade300, thickness: 1),
            const SizedBox(height: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: errors
                  .map(
                    (error) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: color, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              error,
                              style: GoogleFonts.inter(
                                  fontSize: 16, color: Colors.black87),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "OK",
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
