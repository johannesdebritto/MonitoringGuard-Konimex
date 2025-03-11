import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monitoring_guard_frontend/berandapage/beranda.dart';
import 'package:monitoring_guard_frontend/riwayatpage/riwayat.dart';
import 'package:monitoring_guard_frontend/scannernfc/scannernfc.dart';
import 'package:monitoring_guard_frontend/widgets/BottomNavbar.dart';
import 'package:monitoring_guard_frontend/widgets/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Pastikan path ini sesuai dengan lokasi file .env kamu
    await dotenv.load();

    print("✅ .env berhasil dimuat: ${dotenv.env}");
  } catch (e) {
    print("❌ ERROR: Gagal memuat .env - $e");
  }

  print("📌 BASE_URL yang dimuat: ${dotenv.env['BASE_URL']}");

  final prefs = await SharedPreferences.getInstance();
  bool? isFontDownloaded = prefs.getBool('isFontDownloaded');

  GoogleFonts.config.allowRuntimeFetching =
      isFontDownloaded == true ? false : true;

  if (isFontDownloaded == null) {
    await prefs.setBool('isFontDownloaded', true);
  }

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
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const BerandaScreen(),
    const NFCScannerScreen(),
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
          Positioned.fill(child: _pages[_selectedIndex]),
          if (_selectedIndex != 1)
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
