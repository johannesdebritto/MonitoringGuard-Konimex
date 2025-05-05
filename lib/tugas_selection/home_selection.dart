import 'package:flutter/material.dart';

import 'package:monitoring_guard_frontend/tugas_selection/home_selection_form.dart';
import 'package:monitoring_guard_frontend/tugas_selection/home_selection_identitas.dart';

import 'home_selection_logic.dart';

class HomeSelectionScreen extends StatefulWidget {
  const HomeSelectionScreen({super.key});

  @override
  State<HomeSelectionScreen> createState() => _HomeSelectionScreenState();
}

class _HomeSelectionScreenState extends State<HomeSelectionScreen> {
  late HomeSelectionLogic _logic;

  @override
  void initState() {
    super.initState();
    _logic = HomeSelectionLogic(context);
    _logic.loadIdRiwayat();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD00000),
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            color: const Color(0xFFD00000),
          ),
          HomeSelectionIdentitas(
            onLogout: () {},
            onIdRiwayatLoaded: (id, anggotaList) {
              _logic.updateIdRiwayat(id, anggotaList);
            },
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.36,
            left: 0,
            right: 0,
            child: HomeSelectionForm(
              onPatroliDalam: () => _logic.handlePatroli("dalam"),
              onPatroliLuar: () => _logic.handlePatroli("luar"),
            ),
          ),
        ],
      ),
    );
  }
}
