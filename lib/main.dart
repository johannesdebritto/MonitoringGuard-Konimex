import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monitoring_guard_frontend/berandapage/beranda.dart';
import 'package:monitoring_guard_frontend/riwayatpage/riwayat.dart';
import 'package:monitoring_guard_frontend/scannernfc/scannernfc.dart';
import 'package:monitoring_guard_frontend/widgets/BottomNavbar.dart';
import 'package:monitoring_guard_frontend/widgets/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ✅ Tambahkan hanya jika di desktop
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// ✅ Untuk inisialisasi format tanggal lokal
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Hanya inisialisasi SQLite FFI di desktop (Windows, Linux, macOS)
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // ✅ Inisialisasi lokal tanggal
  await initializeDateFormatting('id_ID', null);

  // ✅ Load file .env
  try {
    await dotenv.load();
    print("✅ .env berhasil dimuat: ${dotenv.env}");
  } catch (e) {
    print("❌ ERROR: Gagal memuat .env - $e");
  }

  print("📌 BASE_URL yang dimuat: ${dotenv.env['BASE_URL']}");

  // ✅ Cek apakah font Google sudah dicache
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
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    print("📲 MainNavigation dibuka dengan tipePatroli: ${widget.tipePatroli}");

    _pages = [
      BerandaScreen(tipePatroli: widget.tipePatroli),
      if (widget.tipePatroli == "luar") NFCScannerScreen(),
      RiwayatScreen(tipePatroli: widget.tipePatroli),
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
      body: Stack(
        children: [
          _pages[_selectedIndex],
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: BottomNavbarWidgets(
              selectedIndex: _selectedIndex,
              onItemTapped: _onItemTapped,
              jumlahTombol: _pages.length,
            ),
          ),
        ],
      ),
    );
  }
}
