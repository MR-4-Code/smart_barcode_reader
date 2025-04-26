part of '../smart_barcode_reader.dart';

/// Configuration options for [SmartBarCodeReader].
///
/// This class allows users to customize the barcode scanning behavior without
/// directly interacting with internal classes like [InputClassifier] or
/// [BarcodeValidator]. All fields are optional, and default values are applied
/// by [SmartBarCodeReader] if not specified.
class SmartBarCodeReaderOptions {
  /// Callback invoked when a valid barcode is detected.
  final ValueChanged<String>? onBarcodeDetected;

  /// Regular expression for valid characters in the barcode input.
  /// Defaults to numeric characters only (`r'[0-9]'`).
  final RegExp? validCharPattern;

  /// Set of supported barcode formats (e.g., [BarcodeFormat.ean13]).
  /// Defaults to `{BarcodeFormat.ean13}`.
  final Set<BarcodeFormat>? supportedFormats;

  /// Manager for user feedback (e.g., SnackBar for invalid inputs).
  final UserFeedbackManager? userFeedbackManager;

  /// Minimum length of a valid barcode.
  /// Defaults to 6.
  final int? minLength;

  /// Maximum length of a valid barcode.
  /// Defaults to 13 (for EAN-13).
  final int? maxLength;

  /// Maximum duration (in milliseconds) between key events for scanner input.
  /// Defaults to 20ms.
  final int? maxInterKeyDurationMs;

  /// Tolerance factor for inter-key duration to support slower scanners.
  /// Defaults to 2.5.
  final double? tolerance;

  SmartBarCodeReaderOptions({
    this.onBarcodeDetected,
    this.validCharPattern,
    this.supportedFormats,
    this.userFeedbackManager,
    this.minLength,
    this.maxLength,
    this.maxInterKeyDurationMs,
    this.tolerance,
  });
}
