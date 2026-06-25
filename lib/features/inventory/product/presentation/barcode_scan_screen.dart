import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeScanScreen extends StatefulWidget {
  const BarcodeScanScreen({super.key});
  @override
  State<BarcodeScanScreen> createState() => _State();
}

class _State extends State<BarcodeScanScreen> {
  bool _handled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan barcode')),
      body: MobileScanner(
        onDetect: (capture) {
          if (_handled) return;
          final code = capture.barcodes
              .map((b) => b.rawValue)
              .firstWhere((v) => v != null && v.isNotEmpty, orElse: () => null);
          if (code != null) {
            _handled = true;
            Navigator.of(context).pop(code);
          }
        },
      ),
    );
  }
}
