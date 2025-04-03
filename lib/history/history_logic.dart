import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

enum PatrolType { dalam, luar }

class HistoryState {
  final bool isLoading;
  final bool hasError;
  final Map<String, List<dynamic>> groupedHistoryDalam;
  final Map<String, List<dynamic>> groupedHistoryLuar;
  final PatrolType currentType;

  HistoryState({
    required this.isLoading,
    required this.hasError,
    required this.groupedHistoryDalam,
    required this.groupedHistoryLuar,
    this.currentType = PatrolType.dalam,
  });

  HistoryState copyWith({
    bool? isLoading,
    bool? hasError,
    Map<String, List<dynamic>>? groupedHistoryDalam,
    Map<String, List<dynamic>>? groupedHistoryLuar,
    PatrolType? currentType,
  }) {
    return HistoryState(
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      groupedHistoryDalam: groupedHistoryDalam ?? this.groupedHistoryDalam,
      groupedHistoryLuar: groupedHistoryLuar ?? this.groupedHistoryLuar,
      currentType: currentType ?? this.currentType,
    );
  }

  Map<String, List<dynamic>> get currentHistory {
    return currentType == PatrolType.dalam
        ? groupedHistoryDalam
        : groupedHistoryLuar;
  }
}

class HistoryLogic {
  final ValueNotifier<HistoryState> stateNotifier = ValueNotifier<HistoryState>(
    HistoryState(
      isLoading: true,
      hasError: false,
      groupedHistoryDalam: {},
      groupedHistoryLuar: {},
    ),
  );

  Future<void> fetchHistory({PatrolType type = PatrolType.dalam}) async {
    stateNotifier.value = stateNotifier.value.copyWith(
      isLoading: true,
      hasError: false,
      currentType: type,
    );

    try {
      if (type == PatrolType.dalam) {
        await _fetchHistoryDalam();
      } else {
        await _fetchHistoryLuar();
      }
    } catch (e) {
      print('❌ Error: $e');
      stateNotifier.value = stateNotifier.value.copyWith(
        isLoading: false,
        hasError: true,
      );
    }
  }

  Future<void> _fetchHistoryDalam() async {
    final String apiUrl =
        '${dotenv.env['BASE_URL']}/api/history/history-patroli-dalam/rekap';

    final response = await http.get(Uri.parse(apiUrl));
    _handleResponse(response, isDalam: true);
  }

  Future<void> _fetchHistoryLuar() async {
    final String apiUrl =
        '${dotenv.env['BASE_URL']}/api/history/history-detail-luar';

    final response = await http.get(Uri.parse(apiUrl));
    _handleResponse(response, isDalam: false);
  }

  void _handleResponse(http.Response response, {required bool isDalam}) {
    print('🔍 Status Code: ${response.statusCode}');
    print('📥 Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      Map<String, List<dynamic>> newGroupedHistory = {};
      if (isDalam) {
        if (data['success']) {
          for (var item in data['data']) {
            String idRiwayat = item['id_riwayat'].toString();
            newGroupedHistory[idRiwayat] = [
              ...(newGroupedHistory[idRiwayat] ?? []),
              item
            ];
          }
        }
      } else {
        // 🔹 Menyimpan data patroli luar termasuk nama_unit
        for (var item in data) {
          String idRiwayat = item['id_riwayat'].toString();

          // 🔸 Simpan nama_unit agar bisa ditampilkan di aplikasi
          item['nama_unit'] = item['nama_unit'] ?? 'Unit Tidak Diketahui';

          newGroupedHistory[idRiwayat] = [
            ...(newGroupedHistory[idRiwayat] ?? []),
            item
          ];
        }
      }

      stateNotifier.value = stateNotifier.value.copyWith(
        isLoading: false,
        groupedHistoryDalam: isDalam
            ? newGroupedHistory
            : stateNotifier.value.groupedHistoryDalam,
        groupedHistoryLuar: !isDalam
            ? newGroupedHistory
            : stateNotifier.value.groupedHistoryLuar,
      );
    } else if (response.statusCode == 404) {
      stateNotifier.value = stateNotifier.value.copyWith(
        isLoading: false,
        hasError: false,
        groupedHistoryLuar:
            isDalam ? stateNotifier.value.groupedHistoryLuar : {}, // Set kosong
        groupedHistoryDalam: !isDalam
            ? stateNotifier.value.groupedHistoryDalam
            : {}, // Set kosong
      );
    } else {
      stateNotifier.value = stateNotifier.value.copyWith(
        isLoading: false,
        hasError: true,
      );
    }
  }

  void dispose() {
    stateNotifier.dispose();
  }
}
