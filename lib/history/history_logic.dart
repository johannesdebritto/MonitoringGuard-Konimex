import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:monitoring_guard_frontend/service/db_helper.dart';
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
  static final HistoryLogic _instance = HistoryLogic._internal();
  factory HistoryLogic() => _instance;
  HistoryLogic._internal();

  bool isInitialized = false;

  final ValueNotifier<HistoryState> stateNotifier = ValueNotifier<HistoryState>(
    HistoryState(
      isLoading: true,
      hasError: false,
      groupedHistoryDalam: {},
      groupedHistoryLuar: {},
    ),
  );

  void setType(PatrolType type) {
    final current = stateNotifier.value;
    stateNotifier.value = current.copyWith(currentType: type);
  }

  Future<void> fetchAllHistory() async {
    if (isInitialized) return;

    stateNotifier.value = stateNotifier.value.copyWith(
      isLoading: true,
      hasError: false,
    );

    try {
      final dalamFuture = _fetchHistoryDalam();
      final luarFuture = _fetchHistoryLuar();
      await Future.wait([dalamFuture, luarFuture]);

      isInitialized = true;
      stateNotifier.value = stateNotifier.value.copyWith(
        isLoading: false,
      );
    } catch (e) {
      print('❌ Error saat fetch all: $e');
      stateNotifier.value = stateNotifier.value.copyWith(
        isLoading: false,
        hasError: true,
      );
    }
  }

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
    final String? baseUrl = dotenv.env['BASE_URL'];
    if (baseUrl == null) {
      print('❌ BASE_URL not found in .env');
      return;
    }

    try {
      final response = await http
          .get(Uri.parse('$baseUrl/api/history/history-patroli-dalam/rekap'));
      _handleResponse(response, isDalam: true);
    } catch (e) {
      print('🌐 Gagal fetch dari server, ambil dari SQLite...');
      await _fetchHistoryDalamFromSQLite();
    }
  }

  Future<void> _fetchHistoryLuar() async {
    final String? baseUrl = dotenv.env['BASE_URL'];
    if (baseUrl == null) {
      print('❌ BASE_URL not found in .env');
      return;
    }

    try {
      final response =
          await http.get(Uri.parse('$baseUrl/api/history/history-detail-luar'));
      _handleResponse(response, isDalam: false);
    } catch (e) {
      print('🌐 Gagal fetch dari server, ambil dari SQLite...');
      await _fetchHistoryLuarFromSQLite();
    }
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
        for (var item in data) {
          String idRiwayat = item['id_riwayat'].toString();
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
            isDalam ? stateNotifier.value.groupedHistoryLuar : {},
        groupedHistoryDalam:
            !isDalam ? stateNotifier.value.groupedHistoryDalam : {},
      );
    } else {
      stateNotifier.value = stateNotifier.value.copyWith(
        isLoading: false,
        hasError: true,
      );
    }
  }

  Future<void> _fetchHistoryDalamFromSQLite() async {
    final List<Map<String, dynamic>> localData =
        await DBHelper.getAllDetailRiwayatDalam();

    Map<String, List<dynamic>> grouped = {};
    for (var item in localData) {
      String id = item['id_riwayat'].toString();
      grouped[id] = [...(grouped[id] ?? []), item];
    }

    stateNotifier.value = stateNotifier.value.copyWith(
      isLoading: false,
      groupedHistoryDalam: grouped,
    );
  }

  Future<void> _fetchHistoryLuarFromSQLite() async {
    final List<Map<String, dynamic>> localData =
        await DBHelper.getAllDetailRiwayatLuar();

    Map<String, List<dynamic>> grouped = {};
    for (var item in localData) {
      String id = item['id_riwayat'].toString();
      grouped[id] = [...(grouped[id] ?? []), item];
    }

    stateNotifier.value = stateNotifier.value.copyWith(
      isLoading: false,
      groupedHistoryLuar: grouped,
    );
  }

  void dispose() {
    stateNotifier.dispose();
  }
}
