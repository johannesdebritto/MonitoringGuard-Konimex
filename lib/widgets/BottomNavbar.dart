import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:google_fonts/google_fonts.dart';

class BottomNavbarWidgets extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const BottomNavbarWidgets({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  _BottomNavbarWidgetsState createState() => _BottomNavbarWidgetsState();
}

class _BottomNavbarWidgetsState extends State<BottomNavbarWidgets> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90, // Menyesuaikan tinggi agar tombol scan tidak terpotong
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          // Navbar Merah
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 35, vertical: 5),
            padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.transparent, // Hindari warna putih di belakang
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(60),
              child: Container(
                color: const Color(0xFFD00000), // Warna merah navbar
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNavItem(Iconsax.home_outline, 'Beranda', 0),
                    const SizedBox(width: 70), // Spacer untuk scan button
                    _buildNavItem(Iconsax.clock_outline, 'Riwayat', 2),
                  ],
                ),
              ),
            ),
          ),
          // Tombol Scan
          Positioned(
            bottom: 28, // Mengangkat tombol scan lebih tinggi
            child: _buildScanButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    return GestureDetector(
      onTap: () => widget.onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 30,
            color:
                widget.selectedIndex == index ? Colors.white : Colors.white70,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
          if (widget.selectedIndex == index)
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
        border: Border.all(color: Colors.black, width: 3), // Garis tepi hitam
      ),
      padding: const EdgeInsets.all(8),
      child: IconButton(
        onPressed: () => widget.onItemTapped(1),
        icon: Icon(
          Iconsax.scan_barcode_outline,
          size: 30,
          color: Colors.black,
        ),
      ),
    );
  }
}
