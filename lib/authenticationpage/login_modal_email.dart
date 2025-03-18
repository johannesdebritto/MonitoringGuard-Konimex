import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:convert';

class LoginModalScreen extends StatefulWidget {
  final String initialValue;
  final String fieldType;

  const LoginModalScreen({
    super.key,
    required this.initialValue,
    required this.fieldType,
  });

  @override
  State<LoginModalScreen> createState() => _LoginModalScreenState();
}

class _LoginModalScreenState extends State<LoginModalScreen> {
  late TextEditingController _controller;
  bool _isPasswordVisible = false;
  List<String> _dropdownItems = [];
  bool _isLoading = false;
  bool _isDropdownVisible = false;
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    if (widget.fieldType != "password") {
      _fetchDropdownData();
    }
  }

  void _fetchDropdownData() async {
    setState(() => _isLoading = true);
    String baseUrl = dotenv.env['BASE_URL'] ?? 'http://default-url.com';
    String apiUrl = "$baseUrl/api/auth/unit/list";

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _dropdownItems = data.map((item) => item.toString()).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching data: $e");
      setState(() => _isLoading = false);
    }
  }

  void _showDropdown(BuildContext context) {
    if (_overlayEntry != null) return;
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    setState(() {
      _isDropdownVisible = true;
    });
  }

  void _hideDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() {
      _isDropdownVisible = false;
    });
  }

  OverlayEntry _createOverlayEntry() {
    return OverlayEntry(
      builder: (context) {
        return Positioned(
          width: MediaQuery.of(context).size.width * 0.70,
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
                      title: Text(
                        item,
                        style: GoogleFonts.inter(
                          fontSize: 14, // Ukuran lebih kecil
                          color: Colors.black,
                        ),
                      ),
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
              widget.fieldType == "password"
                  ? "Masukkan Password"
                  : "Pilih Email Unit",
              style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            const SizedBox(height: 16),
            if (widget.fieldType == "password")
              TextField(
                controller: _controller,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible ? LucideIcons.eyeOff : LucideIcons.eye,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
              )
            else
              CompositedTransformTarget(
                link: _layerLink,
                child: GestureDetector(
                  onTap: () {
                    _isDropdownVisible
                        ? _hideDropdown()
                        : _showDropdown(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 10), // Sedikit diperkecil
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          // Supaya teks tidak memaksa turun
                          child: Text(
                            _controller.text.isEmpty
                                ? "Pilih Email"
                                : _controller.text,
                            style: GoogleFonts.inter(
                              fontSize: 14, // Lebih kecil biar gak kepanjangan
                              color: _controller.text.isEmpty
                                  ? Colors.grey
                                  : Colors.black,
                            ),
                            overflow: TextOverflow
                                .ellipsis, // Potong teks kalau kepanjangan
                            maxLines: 1, // Biar tetap satu baris
                            softWrap: false, // Jangan wrap ke bawah
                          ),
                        ),
                        SizedBox(
                          width: 40, // Lebih kecil biar gak terlalu lebar
                          child: Center(
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )
                                : Icon(
                                    _isDropdownVisible
                                        ? LucideIcons.arrowUpCircle
                                        : LucideIcons.arrowDownCircle,
                                    color: Colors.black,
                                    size: 20, // Ukuran icon diperkecil
                                  ),
                          ),
                        ),
                      ],
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
