import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:smart_barcode_reader/smart_barcode_reader.dart';

import 'adaptive_threshold_manager.dart';
import 'input_classifier.dart';
import 'key_event_processor.dart';
import 'validation/barcode_validator.dart';

/// A highly intelligent barcode reader that processes keyboard events to detect
/// barcode scanner input with precision and adaptability.
///
/// The [SmartBarCodeReader] orchestrates multiple components to distinguish barcode
/// scanner input from manual typing, supporting newline (`\n`) termination, adaptive
/// thresholds, and multiple barcode formats (e.g., EAN-13, UPC-A, Code 128).
///
/// Features:
/// - Adaptive thresholds for input speed and length using Exponential Moving Average (EMA).
/// - Scoring-based input classification to filter out manual typing.
/// - Support for EAN-13, UPC-A, and Code 128 checksum validation.
/// - Anomaly detection to reject erratic inputs (e.g., repeated characters, speed spikes).
/// - User feedback via [UserFeedbackManager] for invalid inputs.
///
/// Usage:
/// ```dart
/// SmartBarCodeReader reader = SmartBarCodeReader(
///   onBarcodeDetected: (barcode) => print('Detected barcode: $barcode'),
///   feedbackManager: UserFeedbackManager(context),
/// );
/// ```
class SmartBarCodeReader {
  /// Callback invoked when a valid barcode is detected.
  final ValueChanged<String> onBarcodeDetected;

  /// Minimum length of a valid barcode.
  final int? minLength;

  /// Processor for handling key events and building the input buffer.
  final KeyEventProcessor _eventProcessor;

  /// Validator for checking barcode characters, length, and format.
  final BarcodeValidator _validator;

  /// Classifier for scoring input as scanner or manual typing.
  final InputClassifier _classifier;

  /// Manager for adaptive thresholds (speed and length).
  final AdaptiveThresholdManager _thresholdManager;

  /// Manager for user feedback (e.g., SnackBar notifications).
  final UserFeedbackManager? _feedbackManager;

  /// Timer to detect the end of barcode input.
  Timer? _timer;

  /// Flag to prevent overlapping reads.
  bool _isProcessing = false;

  /// Constructor for [SmartBarCodeReader].
  ///
  /// Parameters:
  /// - [onBarcodeDetected]: Callback invoked with the detected barcode.
  /// - [minLength]: Optional minimum length (defaults to 6 if null).
  /// - [maxLength]: Optional maximum length (defaults to 13 if null).
  /// - [maxInterKeyDurationMs]: Optional maximum time (ms) between keys (defaults to 20 if null).
  /// - [validCharPattern]: Optional RegExp for valid characters (defaults to numeric only if null).
  /// - [supportedFormats]: Set of supported barcode formats (defaults to {EAN-13}).
  /// - [feedbackManager]: Optional manager for user feedback (e.g., SnackBar).
  SmartBarCodeReader({
    required this.onBarcodeDetected,
    this.minLength,
    int? maxLength,
    int? maxInterKeyDurationMs,
    double? tolerance,
    RegExp? validCharPattern,
    Set<BarcodeFormat> supportedFormats = const {BarcodeFormat.ean13},
    UserFeedbackManager? feedbackManager,
  }) : _eventProcessor = KeyEventProcessor(),
       _validator = BarcodeValidator(
         minLength: minLength,
         maxLength: maxLength,
         validCharPattern: validCharPattern,
         supportedFormats: supportedFormats,
       ),
       _classifier = InputClassifier(
         maxInterKeyDurationMs: maxInterKeyDurationMs,
         tolerance: tolerance,
       ),
       _thresholdManager = AdaptiveThresholdManager(
         initialInterKeyDurationMs: maxInterKeyDurationMs?.toDouble(),
         initialMinLength: minLength?.toDouble(),
       ),
       _feedbackManager = feedbackManager;

  /// Handles a keyboard event and processes it as potential barcode input.
  ///
  /// Returns the current barcode buffer for debugging purposes.
  String handleKeyEvent(KeyEvent event) {
    try {
      if (_isProcessing) return _eventProcessor.buffer;

      if (event is KeyDownEvent && event.character != null) {
        _processKeyEvent(event);
      }

      return _eventProcessor.buffer;
    } catch (error, stackTrace) {
      _log('[handleKeyEvent] , $error , $stackTrace');
      _resetState();
      return _eventProcessor.buffer;
    }
  }

  /// Processes a key down event by coordinating with other components.
  void _processKeyEvent(KeyDownEvent event) {
    final character = event.character!;

    // Handle newline termination
    if (character == '\n') {
      _processBarcodeIfValid();
      return;
    }

    _eventProcessor.processKey(character, DateTime.now());

    if (_eventProcessor.buffer.length < (minLength ?? 6)) {
      _log(
        'Input too short, waiting for more characters: ${_eventProcessor.buffer}',
      );
      _resetTimeout();
      return;
    }

    if (!_validator.isValidCharacters(_eventProcessor.buffer)) {
      _feedbackManager?.showFeedback('Invalid barcode characters');
      _log('Invalid characters detected: ${_eventProcessor.buffer}');
      _resetState();
      return;
    }

    // Check for anomalies (e.g., repeated characters, speed spikes)
    if (_isAnomalousInput()) {
      _feedbackManager?.showFeedback('Erratic barcode input detected');
      _log('Anomalous input detected: ${_eventProcessor.buffer}');
      _resetState();
      return;
    }

    // Classify the input
    final score = _classifier.classify(
      _eventProcessor.timestamps,
      _eventProcessor.buffer.length,
      _thresholdManager.adaptiveInterKeyDurationMs,
    );
    if (score < 0.65) {
      _feedbackManager?.showFeedback('Input too slow or invalid');
      _log(
        'Input rejected, low score: ${_eventProcessor.buffer} (score: $score)',
      );
      _resetState();
      return;
    }

    // Wait for expected length (e.g., 13 for EAN-13) or newline
    if (_eventProcessor.buffer.length < 13 &&
        !_eventProcessor.buffer.endsWith('\n')) {
      _log('Waiting for full barcode: ${_eventProcessor.buffer}');
      _resetTimeout();
      return;
    }

    // Update adaptive thresholds
    _thresholdManager.update(
      _eventProcessor.timestamps,
      _eventProcessor.buffer.length,
    );

    _processBarcodeIfValid();
  }

  /// Checks for anomalous input patterns (e.g., repeated characters, speed spikes).
  bool _isAnomalousInput() {
    final buffer = _eventProcessor.buffer;
    final timestamps = _eventProcessor.timestamps;

    // Check for repeated characters (only for short inputs)
    if (buffer.length < 7 && buffer.length >= 3) {
      if (buffer[buffer.length - 1] == buffer[buffer.length - 2] &&
          buffer[buffer.length - 2] == buffer[buffer.length - 3]) {
        return true;
      }
    }

    // Check for speed spikes (high standard deviation)
    if (timestamps.length >= 3) {
      final durations = <double>[];
      for (int i = 1; i < timestamps.length; i++) {
        durations.add(
          timestamps[i].difference(timestamps[i - 1]).inMilliseconds.toDouble(),
        );
      }
      final mean = durations.reduce((a, b) => a + b) / durations.length;
      final variance =
          durations
              .map((d) => (d - mean) * (d - mean))
              .reduce((a, b) => a + b) /
          durations.length;
      final stdDev = sqrt(variance);
      if (stdDev > _thresholdManager.adaptiveInterKeyDurationMs * 2) {
        return true;
      }
    }

    return false;
  }

  /// Processes the barcode if it meets all validation criteria.
  void _processBarcodeIfValid() {
    if (_eventProcessor.buffer.isEmpty || _isProcessing) return;

    _isProcessing = true;

    // Validate length and format
    final validationResult = _validator.validate(_eventProcessor.buffer);
    if (!validationResult.isValid) {
      _feedbackManager?.showFeedback(validationResult.error);
      _log(
        'Validation failed: ${_eventProcessor.buffer} (${validationResult.error})',
      );
      _resetState();
      _isProcessing = false;
      return;
    }

    // Remove trailing newline if present
    final processedBarcode = _eventProcessor.buffer.replaceAll('\n', '');

    _log(
      'Processing barcode: $processedBarcode (score: ${_classifier.classify(_eventProcessor.timestamps, _eventProcessor.buffer.length, _thresholdManager.adaptiveInterKeyDurationMs)})',
    );
    onBarcodeDetected(processedBarcode);
    _resetState();
    _isProcessing = false;
  }

  /// Resets the timeout and schedules barcode processing.
  void _resetTimeout() {
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 300), _processBarcodeIfValid);
  }

  /// Resets the internal state of all components.
  void _resetState() {
    _eventProcessor.reset();
    _timer?.cancel();
  }

  /// Logs a message for debugging purposes.
  void _log(String message) {
    if (!kDebugMode) return;
    debugPrint('[SmartBarCodeReader] $message');
  }

  /// Disposes of resources (e.g., cancels the timer).
  void dispose() {
    _timer?.cancel();
  }
}
