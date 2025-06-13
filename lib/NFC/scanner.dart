import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';

class ScannerScreen extends StatefulWidget {
  @override
  _ScannerScreenState createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  String _status = 'Tempelkan kartu RFID ke HP';
  Color _statusColor = Colors.black;

  @override
  void initState() {
    super.initState();
    _startNFC();
  }

  void _startNFC() async {
    bool isAvailable = await NfcManager.instance.isAvailable();

    if (!isAvailable) {
      setState(() {
        _status = 'NFC tidak tersedia di perangkat ini';
        _statusColor = Colors.red;
      });
      return;
    }

    NfcManager.instance.startSession(
      onDiscovered: (NfcTag tag) async {
        final id = tag.data['nfca']?['identifier'];

        if (id != null) {
          setState(() {
            _status = 'Tag UID: ${_formatUID(id)}';
            _statusColor = Colors.green;
          });
        } else {
          setState(() {
            _status = 'Tag tidak dapat dibaca.';
            _statusColor = Colors.red;
          });
        }

        // Bisa stop kalau cuma ingin scan sekali:
        // NfcManager.instance.stopSession();
      },
    );
  }

  String _formatUID(dynamic bytes) {
    if (bytes is List) {
      return bytes
          .map((b) => b.toRadixString(16).padLeft(2, '0'))
          .join(':')
          .toUpperCase();
    }
    return 'Unknown UID';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('NFC Scanner')),
      body: Center(
        child: Text(
          _status,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, color: _statusColor),
        ),
      ),
    );
  }
}
