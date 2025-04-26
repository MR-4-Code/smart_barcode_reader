import 'package:smart_barcode_reader/smart_barcode_reader.dart';

part 'validation_result.dart';
part 'ean13_validation.dart';
part 'upc_a_validation.dart';
part 'code128_validation.dart';

/// A class responsible for validating barcode input based on length, characters, and format.
///
/// This class checks if the input meets the specified length constraints, contains valid
/// characters, and adheres to the checksum requirements of supported barcode formats
/// (e.g., EAN-13, UPC-A, Code 128).
///
/// Usage:
/// ```dart
/// BarcodeValidator validator = BarcodeValidator(
///   minLength: 6,
///   maxLength: 13,
///   supportedFormats: {BarcodeFormat.ean13, BarcodeFormat.code128},
/// );
/// ValidationResult result = validator.validate('012345678905');
/// print(result.isValid); // true for valid EAN-13
/// ```
class BarcodeValidator {
  /// Minimum length of a valid barcode (default: 6 if null).
  final int? minLength;

  /// Maximum length of a valid barcode (default: 13 if null).
  final int? maxLength;

  /// Regular expression to validate barcode characters (default: numeric only if null).
  final RegExp? validCharPattern;

  /// Supported barcode formats.
  final Set<BarcodeFormat> supportedFormats;

  /// Default values for optional parameters.
  static const _defaultMinLength = 6;
  static const _defaultMaxLength = 20;
  static final _defaultValidCharPattern = RegExp(r'^[0-9]+$');

  /// Constructor for [BarcodeValidator].
  ///
  /// Parameters:
  /// - [minLength]: Optional minimum length (defaults to 6 if null).
  /// - [maxLength]: Optional maximum length (defaults to 13 if null).
  /// - [validCharPattern]: Optional RegExp for valid characters (defaults to numeric only if null).
  /// - [supportedFormats]: Set of supported barcode formats (defaults to {EAN-13}).
  BarcodeValidator({
    this.minLength,
    this.maxLength,
    this.validCharPattern,
    this.supportedFormats = const {BarcodeFormat.ean13},
  });

  /// Validates a barcode input and returns the result.
  ValidationResult validate(String barcode) {
    final effectiveMinLength = minLength ?? _defaultMinLength;
    final effectiveMaxLength = maxLength ?? _defaultMaxLength;

    // Check length
    if (barcode.length < effectiveMinLength) {
      return ValidationResult.failed(
          'Barcode too short: length ${barcode.length} < $effectiveMinLength');
    }
    if (barcode.length > effectiveMaxLength) {
      return ValidationResult.failed(
          'Barcode too long: length ${barcode.length} > $effectiveMaxLength');
    }

    // Check characters
    if (!isValidCharacters(barcode)) {
      return ValidationResult.failed(
          'Invalid characters in barcode: $barcode');
    }

    // Check format-specific validation
    if (supportedFormats.contains(BarcodeFormat.ean13) &&
        barcode.length == 13) {
      if (!_isValidEan13(barcode)) {
        return ValidationResult.failed(
            'Invalid EAN-13 checksum: $barcode');
      }
    }
    if (supportedFormats.contains(BarcodeFormat.upcA) && barcode.length == 12) {
      if (!_isValidUpcA(barcode)) {
        return ValidationResult.failed(
            'Invalid UPC-A checksum: $barcode');
      }
    }
    if (supportedFormats.contains(BarcodeFormat.code128)) {
      if (!_isValidCode128(barcode)) {
        return ValidationResult.failed(
            'Invalid Code 128 checksum: $barcode');
      }
    }

    return ValidationResult.success();
  }

  /// Checks if the barcode contains valid characters.
  bool isValidCharacters(String barcode) {
    final pattern = validCharPattern ?? _defaultValidCharPattern;
    if (pattern == _defaultValidCharPattern) {
      return barcode.codeUnits.every((c) => c >= 48 && c <= 57); // 0-9
    }
    return pattern.hasMatch(barcode);
  }
}
