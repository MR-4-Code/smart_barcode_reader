part of 'barcode_validator.dart';

/// Represents the result of barcode validation.
class ValidationResult {
  ///Whether the barcode is valid.
  final String error;

  /// Error message if the barcode is invalid.
  final bool isValid;

  ValidationResult.failed(this.error) : isValid = false;
  ValidationResult.success()
      : error = '',
        isValid = true;
}
