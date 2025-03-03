import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monitoring_guard_frontend/berandapage/beranda.dart';
import 'package:monitoring_guard_frontend/riwayatpage/riwayat.dart';
import 'package:monitoring_guard_frontend/scannernfc/scannernfc.dart';
import 'package:monitoring_guard_frontend/widgets/BottomNavbar.dart';
import 'package:monitoring_guard_frontend/widgets/splash_screen.dart';

void main() {
  GoogleFonts.config.allowRuntimeFetching = false; // Matikan fetching online
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0; // Indeks halaman aktif

  final List<Widget> _pages = [
    const BerandaScreen(),
    const NFCScannerScreen(), // Ganti Placeholder dengan NFCScannerScreen
    const RiwayatScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
              child: _pages[_selectedIndex]), // Menampilkan konten utama
          if (_selectedIndex !=
              1) // Navbar tidak muncul jika di NFCScannerScreen
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: BottomNavbarWidgets(
                selectedIndex: _selectedIndex,
                onItemTapped: _onItemTapped,
              ),
            ),
        ],
      ),
    );
  }
}
