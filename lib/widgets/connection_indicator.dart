import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

enum IndicatorType { luar, dalam }

class ConnectionIndicator extends StatefulWidget {
  final IndicatorType type;

  const ConnectionIndicator({super.key, this.type = IndicatorType.luar});

  @override
  State<ConnectionIndicator> createState() => _ConnectionIndicatorState();
}

class _ConnectionIndicatorState extends State<ConnectionIndicator> {
  bool _isOnline = true;

  @override
  void initState() {
    super.initState();
    _checkConnection();

    Connectivity().onConnectivityChanged.listen((result) {
      setState(() {
        _isOnline = result != ConnectivityResult.none;
      });
    });
  }

  Future<void> _checkConnection() async {
    var result = await Connectivity().checkConnectivity();
    setState(() {
      _isOnline = result != ConnectivityResult.none;
    });
  }

  @override
  Widget build(BuildContext context) {
    Color iconColor;
    Color textColor;

    if (widget.type == IndicatorType.dalam) {
      iconColor = Colors.white;
      textColor = Colors.white;
    } else {
      iconColor = _isOnline ? Colors.green : Colors.red;
      textColor = _isOnline ? Colors.green : Colors.red;
    }

    return Row(
      children: [
        Icon(
          _isOnline ? Icons.wifi : Icons.wifi_off,
          color: iconColor,
        ),
        const SizedBox(width: 8),
        Text(
          _isOnline ? 'Online' : 'Offline',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
