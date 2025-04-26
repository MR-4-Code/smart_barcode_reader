/// Enum representing supported barcode formats.
enum BarcodeFormat {
  /// EAN-13 barcode format with 13 digits and checksum validation.
  ean13,

  /// UPC-A barcode format with 12 digits, commonly used in retail.
  upcA,

  /// Code 128 barcode format, supporting alphanumeric data with variable length.
  code128,
}