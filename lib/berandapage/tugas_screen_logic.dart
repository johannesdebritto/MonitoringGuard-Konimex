import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:monitoring_guard_frontend/service/db_helper.dart';

class TugasScreenLogic {
  // Singleton pattern
  static final TugasScreenLogic _instance = TugasScreenLogic._internal();
  factory TugasScreenLogic() => _instance;
  TugasScreenLogic._internal();

  List _cachedTugas = [];
  List<dynamic> _tugasList = [];

  List<dynamic> get tugasList => _tugasList;

  final Map<String, Map<String, dynamic>> _cachedRekap = {};
  final Map<String, int> _cachedStatus = {};

  Future<String> loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('anggota_terpilih') ??
        prefs.getString('anggota1') ??
        "Anggota Tidak Diketahui";
  }

  // Dipanggil hanya sekali setelah login
  Future<void> prefetchSemua() async {
    await fetchTugas(force: true);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? idRiwayat = prefs.getString('id_riwayat');
    if (_cachedTugas.isNotEmpty && idRiwayat != null) {
      for (var tugas in _cachedTugas) {
        final idTugas = tugas['id_tugas'].toString();
        await fetchRekap(idTugas, force: true);
        await cekStatusTugas(idTugas, force: true);
      }
    }
  }

  Future<List> fetchTugas({bool force = false}) async {
    if (!force && _cachedTugas.isNotEmpty) {
      _tugasList = _cachedTugas;
      return _cachedTugas;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? idUnit = prefs.getString('id_unit');
    if (idUnit == null) return [];

    try {
      final response = await http
          .get(Uri.parse('${dotenv.env['BASE_URL']}/api/tugas/$idUnit'));

      if (response.statusCode == 200) {
        _cachedTugas = json.decode(response.body);
        _tugasList = _cachedTugas;
        return _cachedTugas;
      } else {
        throw Exception("Gagal mengambil data tugas");
      }
    } catch (e) {
      print("❌ Gagal fetch dari server: $e");
      return [];
    }
  }

  Future<Map<String, dynamic>?> fetchRekap(String idTugas,
      {bool force = false}) async {
    if (!force && _cachedRekap.containsKey(idTugas)) {
      return _cachedRekap[idTugas];
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? idRiwayat = prefs.getString('id_riwayat');

    if (idRiwayat == null || idRiwayat.isEmpty) {
      print("🚨 ID Riwayat tidak ditemukan di SharedPreferences!");
      return null;
    }

    try {
      // === Akses Lokal ===
      final allDetails = await DBHelper.getAllDetailRiwayatLuar();
      final matchingDetail = allDetails.firstWhere(
        (item) =>
            item['id_tugas'].toString() == idTugas.toString() &&
            item['id_riwayat'].toString() == idRiwayat.toString(),
        orElse: () => {},
      );

      if (matchingDetail.isNotEmpty) {
        print("✅ Data ditemukan secara lokal!");
        _cachedRekap[idTugas] = matchingDetail;
        return matchingDetail;
      } else {
        print(
            "⚠️ Data rekap lokal tidak ditemukan untuk id_tugas: $idTugas, id_riwayat: $idRiwayat");
        _cachedRekap[idTugas] = {};
        return {};
      }

      // === Kalau mau aktifkan server lagi, buka komentar ini ===
      /*
    final url = Uri.parse(
        '${dotenv.env['BASE_URL']}/api/tugas/rekap/$idTugas/$idRiwayat');
    print("🔍 Fetching: $url");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      print("✅ Data ditemukan dari server!");
      final data = json.decode(response.body);
      _cachedRekap[idTugas] = data;
      return data;
    } else if (response.statusCode == 404) {
      print("⚠️ Tugas belum dimulai, data masih kosong (server).");
      _cachedRekap[idTugas] = {};
      return {};
    } else {
      print("❌ Gagal fetch rekap dari server: ${response.statusCode} - ${response.body}");
      return null;
    }
    */
    } catch (e) {
      print("❌ Error saat fetch rekap lokal: $e");
      return null;
    }
  }

  Future<int?> cekStatusTugas(String idTugas, {bool force = false}) async {
    if (!force && _cachedStatus.containsKey(idTugas)) {
      return _cachedStatus[idTugas];
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? idRiwayat = prefs.getString('id_riwayat');

    if (idRiwayat == null || idRiwayat.isEmpty) {
      print("🚨 ID Riwayat tidak ditemukan di SharedPreferences!");
      return null;
    }

    // === Cek status tugas di database lokal ===
    final tugas =
        await DBHelper.getDetailRiwayatLuarByIdTugas(idTugas, idRiwayat);

    if (tugas != null) {
      final idStatus = tugas['id_status'] ?? 0;
      _cachedStatus[idTugas] = idStatus;
      return idStatus; // Status ditemukan di lokal
    } else {
      print("⚠️ Tugas tidak ditemukan di database lokal.");
    }

    // === Kalau tidak ada di lokal, cek ke server ===
    /*
  final response = await http.get(
    Uri.parse(
        '${dotenv.env['BASE_URL']}/api/tugas/cek-status/$idTugas/$idRiwayat'),
  );

  print("🔍 Cek status tugas: ${response.request?.url}");

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    _cachedStatus[idTugas] = data['id_status'];
    return data['id_status'];
  } else if (response.statusCode == 404) {
    print("⚠️ Tidak ada tugas ditemukan, dianggap kosong.");
    _cachedStatus[idTugas] = 0;
    return 0;
  } else {
    print(
        "❌ Gagal mengecek status tugas: ${response.statusCode} - ${response.body}");
    return null;
  }
  */
    return null;
  }

  void clearCache() {
    _cachedTugas = [];
    _cachedRekap.clear();
    _cachedStatus.clear();
    _tugasList = [];
  }

  void setTugasList(List<dynamic> tugas) {
    _tugasList = tugas;
  }
}
