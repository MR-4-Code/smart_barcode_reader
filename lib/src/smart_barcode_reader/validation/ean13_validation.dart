part of 'barcode_validator.dart';


/// Validates EAN-13 checksum.
bool _isValidEan13(String barcode) {
  if (barcode.length != 13) return false;
  int sum = 0;
  for (int i = 0; i < 12; i++) {
    final digit = int.parse(barcode[i]);
    sum += i % 2 == 0 ? digit : 3 * digit;
  }
  final checksum = (10 - (sum % 10)) % 10;
  return checksum == int.parse(barcode[12]);
}