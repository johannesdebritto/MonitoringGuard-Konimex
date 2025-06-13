import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monitoring_guard_frontend/NFC/scanner_modal.dart';

class BottomNavbarWidgets extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  final int jumlahTombol;

  const BottomNavbarWidgets({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
    required this.jumlahTombol,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          // Navbar Merah
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 35, vertical: 5),
            padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(60),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(60),
              child: Container(
                color: const Color(0xFFD00000),
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNavItem(Iconsax.home_outline, 'Beranda', 0),
                    if (jumlahTombol == 3) const SizedBox(width: 70),
                    _buildNavItem(Iconsax.clock_outline, 'Riwayat',
                        jumlahTombol == 3 ? 2 : 1),
                  ],
                ),
              ),
            ),
          ),
          // Tombol Scan (hanya muncul jika jumlah tombol == 3)
          if (jumlahTombol == 3)
            Positioned(
              bottom: 20, // Mengurangi efek menaikkan layout
              child: _buildScanButton(),
            ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    return GestureDetector(
      onTap: () => onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 30,
            color: selectedIndex == index ? Colors.white : Colors.white70,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
          if (selectedIndex == index)
            Container(
              width: 20,
              height: 2,
              color: Colors.white,
              margin: const EdgeInsets.only(top: 2),
            ),
        ],
      ),
    );
  }

  Widget _buildScanButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black, width: 3),
      ),
      padding: const EdgeInsets.all(8),
      child: Builder(
        builder: (context) => IconButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              isScrollControlled: true,
              builder: (context) => ScannerNFCModal(
                onItemTapped: onItemTapped, // dari parent
              ),
            );
          },
          icon: const Icon(
            Iconsax.scan_barcode_outline,
            size: 30,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
