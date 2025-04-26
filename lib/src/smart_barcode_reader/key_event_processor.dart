import 'circular_buffer.dart';

/// A class responsible for processing key events and building the barcode input buffer.
///
/// This class maintains a circular buffer of timestamps and a string buffer for
/// characters, allowing efficient tracking of input timing and content.
///
/// Usage:
/// ```dart
/// KeyEventProcessor processor = KeyEventProcessor();
/// processor.processKey('1', DateTime.now());
/// print(processor.buffer); // '1'
/// ```
class KeyEventProcessor {
  /// Buffer for storing input characters.
  String _buffer = '';

  /// Circular buffer for storing timestamps of key events (max 100 entries).
  final CircularBuffer<DateTime> _timestamps = CircularBuffer<DateTime>(100);

  /// Gets the current input buffer.
  String get buffer => _buffer;

  /// Gets the timestamps of key events.
  CircularBuffer<DateTime> get timestamps => _timestamps;

  /// Processes a key event by adding the character and timestamp.
  void processKey(String character, DateTime timestamp) {
    _buffer += character;
    _timestamps.add(timestamp);
  }

  /// Resets the buffer and timestamps.
  void reset() {
    _buffer = '';
    _timestamps.clear();
  }
}