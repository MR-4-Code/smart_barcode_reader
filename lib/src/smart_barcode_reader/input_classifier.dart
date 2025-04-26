import 'dart:math';
import 'package:flutter/foundation.dart';
import 'circular_buffer.dart';

/// Tolerance factor for calculating the maximum allowed inter-key duration.
///
/// This constant determines how lenient the classifier is when evaluating the
/// time intervals between key events (`maxDuration`). It is multiplied by
/// `adaptiveInterKeyDurationMs` to set the threshold for acceptable intervals.
/// A higher tolerance allows larger intervals (slower inputs), making the
/// classifier more accepting of slower scanners or variable input speeds.
/// The value 2.5 was chosen to accommodate scanners with inter-key durations
/// up to ~39ms (based on observed maxDuration of ~16ms in logs), improving
/// detection reliability for diverse hardware.
double _tolerance = 2.5;

/// A class responsible for classifying input as barcode scanner or manual typing.
///
/// This class calculates a score (0-1) based on input speed and length, using
/// adaptive thresholds. A score above the threshold (0.65) indicates scanner input.
///
/// Usage:
/// ```dart
/// InputClassifier classifier = InputClassifier(maxInterKeyDurationMs: 20);
/// double score = classifier.classify(timestamps, length, 15.0);
/// print(score); // e.g., 0.85 for scanner input
/// ```
class InputClassifier {
  /// Maximum time (ms) between keys for scanner input (default: 20 if null).
  final int? maxInterKeyDurationMs;

  /// Constructor for [InputClassifier].
  ///
  /// Parameters:
  /// - [maxInterKeyDurationMs]: Optional maximum time (ms) between keys (defaults to 20 if null).
  InputClassifier({this.maxInterKeyDurationMs, double? tolerance}) {
    if (tolerance != null) _tolerance = tolerance;
  }

  /// Calculates a score for the input based on speed and length.
  ///
  /// Parameters:
  /// - [timestamps]: Circular buffer of key event timestamps.
  /// - [length]: Length of the input buffer.
  /// - [adaptiveInterKeyDurationMs]: Adaptive threshold for inter-key duration.
  ///
  /// Returns a score between 0 and 1 (higher indicates scanner input).
  double classify(CircularBuffer<DateTime> timestamps, int length,
      double adaptiveInterKeyDurationMs) {
    final speedScore = _getSpeedScore(timestamps, adaptiveInterKeyDurationMs);
    final lengthScore = _getLengthScore(length);

    final score = 0.6 * speedScore + 0.4 * lengthScore;
    debugPrint(
        '[InputClassifier] Score: $score (speed: $speedScore, length: $lengthScore, length: $length)');
    return score;
  }

  /// Calculates a score based on input speed.
  double _getSpeedScore(
      CircularBuffer<DateTime> timestamps, double adaptiveInterKeyDurationMs) {
    if (timestamps.length < 2) return 1.0;
    double maxDuration = 0;
    for (int i = 1; i < timestamps.length; i++) {
      final duration =
          timestamps[i].difference(timestamps[i - 1]).inMilliseconds.toDouble();
      maxDuration = max(maxDuration, duration);
    }

    final threshold = adaptiveInterKeyDurationMs * _tolerance;
    final speedScore = max(0.0, 1.0 - maxDuration / threshold);
    debugPrint(
        '[InputClassifier] SpeedScore: maxDuration=$maxDuration, threshold=$threshold, score=$speedScore');

    return speedScore;
  }

  /// Calculates a score based on input length.
  double _getLengthScore(int length) {
    const minLength = 6;
    if (length < minLength) {
      // Increased tolerance by 20%
      return min(1.0, (length / minLength) * 1.2);
    }
    return 1.0;
  }
}
