import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:lucide_icons/lucide_icons.dart';

class LoginModalUnitPatroli extends StatefulWidget {
  final String initialValue;
  final String fieldType;

  const LoginModalUnitPatroli({
    super.key,
    required this.initialValue,
    required this.fieldType,
  });

  @override
  State<LoginModalUnitPatroli> createState() => _LoginModalUnitPatroliState();
}

class _LoginModalUnitPatroliState extends State<LoginModalUnitPatroli> {
  late TextEditingController _controller;
  bool _isDropdownVisible = false;
  bool _isLoading = false;
  List<String> _dropdownItems = [];
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _fetchDropdownData();
  }

  Future<void> _fetchDropdownData() async {
    setState(() => _isLoading = true);
    String baseUrl = dotenv.env['BASE_URL'] ?? 'http://default-url.com';
    String apiUrl = widget.fieldType == "unit_anggota"
        ? "$baseUrl/api/auth/unit_kerja/list"
        : "$baseUrl/api/auth/patroli/list";

    try {
      final response = await http.get(Uri.parse(apiUrl));

      // Cek isi JSON sebelum diproses
      print("Response: ${response.body}");

      if (response.statusCode == 200) {
        final dynamic jsonData = json.decode(response.body);

        // Pastikan jsonData berbentuk List
        if (jsonData is List) {
          setState(() {
            _dropdownItems = jsonData
                .map((item) => item is Map<String, dynamic>
                    ? item["nama"].toString()
                    : item.toString())
                .toList();
          });
        } else {
          print("Error: JSON bukan list");
        }
      }
    } catch (e) {
      print("Error fetching data: $e");
    }

    setState(() => _isLoading = false);
  }

  void _showDropdown() {
    if (_overlayEntry != null) return;
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    setState(() => _isDropdownVisible = true);
  }

  void _hideDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() => _isDropdownVisible = false);
  }

  OverlayEntry _createOverlayEntry() {
    return OverlayEntry(
      builder: (context) {
        return Positioned(
          width: MediaQuery.of(context).size.width * 0.90,
          child: CompositedTransformFollower(
            link: _layerLink,
            offset: const Offset(0, 60),
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.black, width: 2),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: _dropdownItems.map((item) {
                    return ListTile(
                      title: Text(item,
                          style: const TextStyle(color: Colors.black)),
                      onTap: () {
                        setState(() {
                          _controller.text = item;
                          _hideDropdown();
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.fieldType == "unit_anggota"
                  ? "Unit Anggota"
                  : "Patroli Anggota",
              style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            const SizedBox(height: 16),
            CompositedTransformTarget(
              link: _layerLink,
              child: GestureDetector(
                onTap: () {
                  _isDropdownVisible ? _hideDropdown() : _showDropdown();
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                  child: IntrinsicHeight(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            _controller.text.isEmpty
                                ? "Pilih ${widget.fieldType == "unit_anggota" ? "Unit Anggota" : "Patroli Anggota"}"
                                : _controller.text,
                            style: GoogleFonts.robotoSlab(
                              fontSize: 16,
                              color: _controller.text.isEmpty
                                  ? Colors.grey
                                  : Colors.black,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 50,
                          child: Center(
                            child: _isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2))
                                : Icon(
                                    _isDropdownVisible
                                        ? LucideIcons.arrowUpCircle
                                        : LucideIcons.arrowDownCircle,
                                    color: Colors.black,
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  style: TextButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () => Navigator.pop(context),
                  child: Text("Batal",
                      style: GoogleFonts.inter(color: Colors.white)),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  onPressed: () => Navigator.pop(context, _controller.text),
                  child: Text("Simpan",
                      style: GoogleFonts.inter(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
