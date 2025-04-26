import 'package:flutter/material.dart' show MaterialApp;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_barcode_reader/smart_barcode_reader.dart';

void main() {
  final options = SmartBarCodeReaderOptions(
      onBarcodeDetected: (barcode) {},
      minLength: 6,
      maxLength: 13,
      maxInterKeyDurationMs: 30,
      tolerance: 2.5,
      validCharPattern: RegExp(r'[0-9]'),
      supportedFormats: {BarcodeFormat.ean13});

  group('SmartBarCodeReaderOptions', () {
    test('should store configuration correctly', () {
      expect(options.minLength, 6);
      expect(options.maxLength, 13);
      expect(options.maxInterKeyDurationMs, 30);
      expect(options.tolerance, 2.5);
      expect(options.validCharPattern, RegExp(r'[0-9]'));
      expect(options.supportedFormats, {BarcodeFormat.ean13});
      expect(options.onBarcodeDetected, isNotNull);
    });

    test('should handle null values correctly', () {
      final options = SmartBarCodeReaderOptions();

      expect(options.minLength, isNull);
      expect(options.maxLength, isNull);
      expect(options.maxInterKeyDurationMs, isNull);
      expect(options.tolerance, isNull);
      expect(options.validCharPattern, isNull);
      expect(options.supportedFormats, isNull);
      expect(options.onBarcodeDetected, isNull);
    });
  });

  group('SmartBarCodeScannerWidget', () {
    testWidgets('should render child correctly', (WidgetTester tester) async {
      final options = SmartBarCodeReaderOptions(
        onBarcodeDetected: (barcode) {},
      );

      await tester.pumpWidget(
        MaterialApp(
          home: SmartBarCodeReaderWidget(
            options: options,
            child: Text('Scan a barcode'),
          ),
        ),
      );

      expect(find.text('Scan a barcode'), findsOneWidget);
    });
  });
}
