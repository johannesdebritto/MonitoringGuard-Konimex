import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginModalScreen extends StatefulWidget {
  final String initialValue;
  final String fieldType; // "email", "password", "unit", "pegawai"

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
  bool _obscure = true; // Untuk password
  List<String> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  // Fungsi untuk mencari unit atau pegawai berdasarkan input user
  void _searchData(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    String baseUrl = dotenv.env['BASE_URL'] ?? 'http://default-url.com';
    String apiUrl;

    if (widget.fieldType == "email") {
      apiUrl = "$baseUrl/api/auth/unit/search?q=$query";
    } else if (widget.fieldType == "pegawai") {
      apiUrl = "$baseUrl/api/auth/anggota/search?q=$query";
    } else {
      return; // Jika bukan unit atau pegawai, tidak perlu API
    }

    final url = Uri.parse(apiUrl);
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        _searchResults = data.map((item) => item.toString()).toList();
      });
    }
  }

  // Fungsi untuk menyorot teks pencarian dalam dropdown
  TextSpan highlightMatch(String text, String query) {
    if (query.isEmpty) {
      return TextSpan(text: text, style: const TextStyle(color: Colors.black));
    }

    final RegExp regExp = RegExp(query, caseSensitive: false);
    final Iterable<Match> matches = regExp.allMatches(text);

    if (matches.isEmpty) {
      return TextSpan(text: text, style: const TextStyle(color: Colors.black));
    }

    List<TextSpan> spans = [];
    int lastMatchEnd = 0;

    for (Match match in matches) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(
          text: text.substring(lastMatchEnd, match.start),
          style: const TextStyle(color: Colors.black),
        ));
      }

      spans.add(TextSpan(
        text: text.substring(match.start, match.end),
        style: const TextStyle(
          color: Colors.black,
          backgroundColor: Color(0xFFFFFF99), // Warna kuning muda
          fontWeight: FontWeight.bold,
        ),
      ));

      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastMatchEnd),
        style: const TextStyle(color: Colors.black),
      ));
    }

    return TextSpan(children: spans);
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
                  : widget.fieldType == "email"
                      ? "Masukkan Email"
                      : widget.fieldType == "pegawai"
                          ? "Masukkan Nama Pegawai"
                          : "Masukkan Data",
              style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              obscureText: widget.fieldType == "password" ? _obscure : false,
              autofocus: true,
              style: const TextStyle(color: Colors.black),
              onChanged: (value) =>
                  _searchData(value), // Panggil API saat mengetik
              decoration: InputDecoration(
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                suffixIcon: widget.fieldType == "password"
                    ? IconButton(
                        icon: Icon(
                          _obscure
                              ? Iconsax.eye_slash_outline
                              : Iconsax.eye_outline,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscure = !_obscure;
                          });
                        },
                      )
                    : null,
              ),
            ),
            if (_searchResults.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(color: Colors.grey.shade300, blurRadius: 4),
                  ],
                ),
                child: Column(
                  children: _searchResults.map((item) {
                    return ListTile(
                      title: RichText(
                        text: highlightMatch(
                            item, _controller.text), // Highlight teks pencarian
                      ),
                      onTap: () {
                        setState(() {
                          _controller.text = item;
                          _searchResults =
                              []; // Hilangkan dropdown setelah memilih
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text("Batal",
                      style: GoogleFonts.inter(color: Colors.white)),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF38B000),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    Navigator.pop(context, _controller.text);
                  },
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
