import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginModalAnggota extends StatefulWidget {
  final String initialValue;
  final String anggotaType;

  const LoginModalAnggota({
    super.key,
    required this.initialValue,
    required this.anggotaType,
  });

  @override
  State<LoginModalAnggota> createState() => _LoginModalAnggotaState();
}

class _LoginModalAnggotaState extends State<LoginModalAnggota> {
  late TextEditingController _controller;
  List<String> _suggestions = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  void _fetchSuggestions(String query) async {
    if (query.isEmpty) {
      setState(() => _suggestions = []);
      return;
    }

    setState(() => _isLoading = true);
    String baseUrl = dotenv.env['BASE_URL'] ?? 'http://default-url.com';
    String apiUrl = "$baseUrl/api/auth/anggota/search?q=$query";

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _suggestions = data.map((item) => item.toString()).toList();
        });
      } else {
        print("Error API: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching data: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildSuggestionList() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: _suggestions.length,
      itemBuilder: (context, index) {
        String name = _suggestions[index];
        String query = _controller.text.toLowerCase();
        List<TextSpan> textSpans = [];

        int startIndex = name.toLowerCase().indexOf(query);
        if (startIndex != -1) {
          textSpans.add(
            TextSpan(
              text: name.substring(startIndex, startIndex + query.length),
              style: const TextStyle(
                  fontWeight: FontWeight.bold, backgroundColor: Colors.yellow),
            ),
          );
        }

        return ListTile(
          title: RichText(
            text: TextSpan(
              text: name.substring(0, startIndex),
              style: const TextStyle(color: Colors.black),
              children: textSpans +
                  [TextSpan(text: name.substring(startIndex + query.length))],
            ),
          ),
          onTap: () {
            setState(() {
              _controller.text = name;
              _suggestions.clear();
            });
          },
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
              "Pilih ${widget.anggotaType}",
              style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              autofocus: true,
              onChanged: _fetchSuggestions,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              ),
            ),
            if (_suggestions.isNotEmpty) _buildSuggestionList(),
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
                    backgroundColor: Colors.green,
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
