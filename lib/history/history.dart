import 'package:flutter/material.dart';
import 'history_dalam.dart';
import 'history_luar.dart';
import 'history_logic.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final HistoryLogic _logic = HistoryLogic();

  @override
  void initState() {
    super.initState();
    _logic.fetchHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Patroli'),
        backgroundColor: Colors.blue.shade900,
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildTypeSelector(),
          Expanded(
            child: ValueListenableBuilder<HistoryState>(
              valueListenable: _logic.stateNotifier,
              builder: (context, state, _) {
                if (state.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state.hasError) {
                  return const Center(
                      child: Text('Terjadi kesalahan saat mengambil data'));
                } else if (state.currentHistory.isEmpty) {
                  return const Center(child: Text('Tidak ada data'));
                } else {
                  return state.currentType == PatrolType.dalam
                      ? HistoryDalamView(
                          groupedHistory: state.groupedHistoryDalam)
                      : HistoryLuarView(
                          groupedHistory: state.groupedHistoryLuar);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: ValueListenableBuilder<HistoryState>(
        valueListenable: _logic.stateNotifier,
        builder: (context, state, _) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildCustomButton(
                label: 'Patroli Dalam',
                icon: Icons.security,
                selected: state.currentType == PatrolType.dalam,
                onTap: () => _logic.fetchHistory(type: PatrolType.dalam),
                color: Colors.blue.shade700,
              ),
              const SizedBox(width: 16),
              _buildCustomButton(
                label: 'Patroli Luar',
                icon: Icons.directions_walk,
                selected: state.currentType == PatrolType.luar,
                onTap: () => _logic.fetchHistory(type: PatrolType.luar),
                color: Colors.orange.shade700,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCustomButton({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        decoration: BoxDecoration(
          color: selected ? color : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            if (selected)
              BoxShadow(
                color: color.withOpacity(0.5),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: selected ? Colors.white : Colors.black54),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: selected ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _logic.dispose();
    super.dispose();
  }
}
