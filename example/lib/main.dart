import 'package:flutter/material.dart';
import 'package:smart_barcode_reader/smart_barcode_reader.dart';

void main() {
  runApp(const SmartBarcodeReaderExample());
}

class SmartBarcodeReaderExample extends StatelessWidget {
  const SmartBarcodeReaderExample({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Smart Barcode Reader Demo')),
        body: SmartBarCodeReaderWidget(
          options: SmartBarCodeReaderOptions(
            onBarcodeDetected: (barcode) {
              debugPrint('Scanned barcode: $barcode');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Barcode: $barcode')),
              );
            },
            minLength: 6,
            maxLength: 13,
            maxInterKeyDurationMs: 30,
            tolerance: 2.5,
          ),
          child: const Center(
            child: Text(
              'Scan a barcode',
              style: TextStyle(fontSize: 20),
            ),
          ),
        ),
      ),
    );
  }
}