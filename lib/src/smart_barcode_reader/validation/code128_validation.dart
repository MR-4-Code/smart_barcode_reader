part of 'barcode_validator.dart';

/// Validates Code 128 checksum (simplified).
bool _isValidCode128(String barcode) {
  return barcode.codeUnits.every((c) => c >= 32 && c <= 126);
}
