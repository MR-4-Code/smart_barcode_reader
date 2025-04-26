part of 'barcode_validator.dart';

/// Validates UPC-A checksum.
bool _isValidUpcA(String barcode) {
  if (barcode.length != 12) return false;
  int sum = 0;
  for (int i = 0; i < 11; i++) {
    final digit = int.parse(barcode[i]);
    sum += i % 2 == 0 ? 3 * digit : digit;
  }
  final checksum = (10 - (sum % 10)) % 10;
  return checksum == int.parse(barcode[11]);
}
