# smart_barcode_reader

A Flutter package for intelligently detecting and processing barcode scanner inputs, with support for formats like EAN-13. This package distinguishes scanner inputs from manual typing using adaptive speed and length validation, making it ideal for Point of Sale (POS) applications.

[![Pub Version](https://img.shields.io/pub/v/smart_barcode_reader)](https://pub.dev/packages/smart_barcode_reader)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Features

- **Intelligent Detection**: Differentiates barcode scanner inputs from manual typing using adaptive thresholds for speed and input length.
- **Barcode Format Support**: Validates EAN-13 barcodes with checksum verification (more formats coming soon).
- **User Feedback**: Provides customizable feedback (e.g., SnackBar notifications) for invalid or slow inputs.
- **High Tolerance**: Handles slower scanners with configurable inter-key duration tolerance (default: 2.5x adaptive threshold).
- **Lightweight**: Pure Dart/Flutter implementation with minimal dependencies, perfect for POS and inventory applications.

## Installation

Add `smart_barcode_reader` to your `pubspec.yaml`:

```yaml
dependencies:
  smart_barcode_reader: ^0.0.1
```

> **Tip**: To access the latest features before official releases, use the `dev` branch:
>
> ```yaml
> dependencies:
>   smart_barcode_reader:
>     git:
>       url: https://github.com/MR-4-Code/smart_barcode_reader.git
>       ref: dev
> ```

Then run:

```bash
flutter pub get
```

## Usage

Below is a simple example of using `SmartBarCodeReader` in a Flutter application to detect barcode inputs and display them.

```dart
import 'package:flutter/material.dart';
import 'package:smart_barcode_reader/smart_barcode_reader.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Barcode Scanner Demo')),
        body: SmartBarCodeScannerWidget(
          options: SmartBarCodeReaderOptions(
            onBarcodeDetected: (barcode) {
              print('Scanned barcode: $barcode');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Barcode: $barcode')),
              );
            },
          ),
          child: Center(child: Text('Scan a barcode')),
        ),
      ),
    );
  }
}
```

### Steps:
1. Wrap your widget tree with `SmartBarCodeScannerWidget`.
2. Provide an `onBarcodeDetected` callback to handle detected barcodes.
3. Optionally, configure `SmartBarCodeReaderOptions` for custom settings.

## Configuration

You can customize `SmartBarCodeReader` with the following options in `SmartBarCodeReaderOptions`:

- `onBarcodeDetected`: Callback for detected barcodes.
- `minLength`: Minimum barcode length (default: 6).
- `maxLength`: Maximum barcode length (default: 13 for EAN-13).
- `maxInterKeyDurationMs`: Maximum time (ms) between key events (default: 20ms).
- `validCharPattern`: RegExp for valid characters (default: numeric only).
- `supportedFormats`: Set of supported barcode formats (default: `{BarcodeFormat.ean13}`).
- `tolerance`: Tolerance for slower scanners (default: 2.5).
- `userFeedbackManager`: Custom feedback manager for user notifications.

Example with custom configuration:

```dart
SmartBarCodeScannerWidget(
  options: SmartBarCodeReaderOptions(
    onBarcodeDetected: (barcode) => print('Barcode: $barcode'),
    minLength: 6,
    maxLength: 13,
    maxInterKeyDurationMs: 30,
    tolerance: 2.5,
  ),
  child: Center(child: Text('Scan a barcode')),
)
```

## Contributing

Contributions are welcome! To contribute:

1. Fork the repository.
2. Create a new branch (`git checkout -b feature/your-feature`).
3. Make your changes and commit (`git commit -m 'Add your feature'`).
4. Push to the branch (`git push origin feature/your-feature`).
5. Open a Pull Request.

Please ensure your code follows the [Flutter style guide](https://flutter.dev/docs/development/tools/formatting) and includes tests.

## Issues

If you encounter any issues or have feature requests, please file them on the [issue tracker](https://github.com/MR-4-Code/smart_barcode_reader/issues).

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contact

For questions or support, reach out via the [GitHub repository](https://github.com/MR-4-Code/smart_barcode_reader) or open an issue.

---

Built with 💙 for Flutter developers.

**Author**: MerDEV 2025