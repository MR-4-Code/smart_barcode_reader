import 'circular_buffer.dart';

/// A class responsible for managing adaptive thresholds for barcode input.
///
/// This class uses Exponential Moving Average (EMA) to adapt thresholds for
/// inter-key duration and minimum length based on input patterns.
///
/// Usage:
/// ```dart
/// AdaptiveThresholdManager manager = AdaptiveThresholdManager(
///   initialInterKeyDurationMs: 20,
///   initialMinLength: 6,
/// );
/// manager.update(timestamps, 13);
/// print(manager.adaptiveInterKeyDurationMs); // e.g., 18.5
/// ```
class AdaptiveThresholdManager {
  /// Current adaptive threshold for inter-key duration (ms).
  double _adaptiveInterKeyDurationMs;

  /// Current adaptive threshold for minimum length.
  double _adaptiveMinLength;

  /// EMA smoothing factor (0 to 1, higher means more responsive).
  static const _alpha = 0.1;

  /// Constructor for [AdaptiveThresholdManager].
  ///
  /// Parameters:
  /// - [initialInterKeyDurationMs]: Initial inter-key duration threshold (ms).
  /// - [initialMinLength]: Initial minimum length threshold.
  AdaptiveThresholdManager({
    double? initialInterKeyDurationMs,
    double? initialMinLength,
  })  : _adaptiveInterKeyDurationMs = initialInterKeyDurationMs ?? 20.0,
        _adaptiveMinLength = initialMinLength ?? 6.0;

  /// Gets the current adaptive inter-key duration threshold.
  double get adaptiveInterKeyDurationMs => _adaptiveInterKeyDurationMs;

  /// Gets the current adaptive minimum length threshold.
  double get adaptiveMinLength => _adaptiveMinLength;

  /// Updates the adaptive thresholds based on new input.
  void update(CircularBuffer<DateTime> timestamps, int length) {
    // Update inter-key duration
    if (timestamps.length >= 2) {
      double totalDuration = 0;
      int count = 0;
      for (int i = 1; i < timestamps.length; i++) {
        totalDuration += timestamps[i]
            .difference(timestamps[i - 1])
            .inMilliseconds
            .toDouble();
        count++;
      }
      final avgDuration = totalDuration / count;
      _adaptiveInterKeyDurationMs = (1 - _alpha) * _adaptiveInterKeyDurationMs +
          _alpha * avgDuration;
    }

    // Update minimum length
    _adaptiveMinLength =
        (1 - _alpha) * _adaptiveMinLength + _alpha * length.toDouble();
  }
}