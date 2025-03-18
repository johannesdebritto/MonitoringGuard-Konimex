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
  final String tipePatroli;

  const MainNavigation({super.key, required this.tipePatroli});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  late List<Widget>
      _pages; // Menggunakan 'late' agar bisa diinisialisasi di initState()

  @override
  void initState() {
    super.initState();

    // Buat daftar halaman berdasarkan tipePatroli
    _pages = [
      BerandaScreen(tipePatroli: widget.tipePatroli), // Beranda tetap ada
      if (widget.tipePatroli == "luar")
        NFCScannerScreen(), // Scanner hanya untuk "luar"
      RiwayatScreen(tipePatroli: widget.tipePatroli), // Riwayat tetap ada
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavbarWidgets(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
        jumlahTombol: _pages.length, // Jumlah tombol di navbar menyesuaikan
      ),
    );
  }
}
