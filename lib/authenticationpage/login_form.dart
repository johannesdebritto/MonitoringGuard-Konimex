import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monitoring_guard_frontend/authenticationpage/email_form.dart';
import 'package:monitoring_guard_frontend/authenticationpage/anggota_form.dart';
import 'package:monitoring_guard_frontend/authenticationpage/login_logic.dart';
import 'package:monitoring_guard_frontend/authenticationpage/unit_patroli_form.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Variabel untuk menyimpan input dari user
  String _email = "";
  String _password = "";
  String _anggota1 = "";
  String _anggota2 = "";
  String _patroli = "";
  String _unitKerja = "";

  final LoginLogic _loginLogic = LoginLogic();

  void nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2C3E50).withOpacity(0.95),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title
          Center(
            child: Text(
              "LOGIN",
              style: GoogleFonts.robotoSlab(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Form Input
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: SizedBox(
              height: _currentPage == 0 ? 180 : 280, // Sesuaikan tinggi halaman
              child: PageView(
                controller: _pageController,
                physics:
                    const NeverScrollableScrollPhysics(), // Hanya pindah dengan tombol
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  // Form Email dan Password
                  EmailPasswordForm(
                    email: _email,
                    password: _password,
                    onChanged: (email, password) {
                      setState(() {
                        _email = email;
                        _password = password;
                      });
                    },
                  ),

                  // Form Anggota dan Unit Patroli
                  SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Form Anggota
                        AnggotaForm(
                          pegawai: _anggota1,
                          anggota2: _anggota2,
                          onPegawaiChanged: (pegawai) {
                            setState(() {
                              _anggota1 = pegawai;
                            });
                          },
                          onAnggota2Changed: (anggota) {
                            setState(() {
                              _anggota2 = anggota;
                            });
                          },
                        ),
                        const SizedBox(height: 15),

                        // Form Unit Patroli
                        UnitPatroliForm(
                          unitAnggota: _unitKerja, // Perbaikan nama variabel
                          patroliAnggota: _patroli,
                          onUnitAnggotaChanged: (unit) {
                            setState(() {
                              _unitKerja = unit;
                            });
                          },
                          onPatroliAnggotaChanged: (patroli) {
                            setState(() {
                              _patroli = patroli;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Tombol Navigasi dan Login
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_currentPage == 1)
                ElevatedButton(
                  onPressed: previousPage,
                  child: const Text("BACK"),
                ),
              if (_currentPage == 0)
                ElevatedButton(
                  onPressed: nextPage,
                  child: const Text("NEXT"),
                ),
              if (_currentPage == 1)
                ElevatedButton(
                  onPressed: () {
                    _loginLogic.login(
                      context: context,
                      email: _email,
                      password: _password,
                      anggota1: _anggota1,
                      anggota2: _anggota2.isNotEmpty ? _anggota2 : null,
                      patroli: _patroli,
                      unitKerja: _unitKerja,
                    );
                  },
                  child: const Text("MASUK"),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
