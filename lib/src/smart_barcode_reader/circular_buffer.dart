/// A fixed-size circular buffer for storing elements of type [R].
///
/// This class provides O(1) operations for adding elements and accessing them
/// by index. When the buffer is full, new elements overwrite the oldest ones.
///
/// Usage:
/// ```dart
/// CircularBuffer<int> buffer = CircularBuffer(3);
/// buffer.add(1);
/// buffer.add(2);
/// print(buffer[0]); // 1
/// ```
class CircularBuffer<R> {
  final List<R?> _buffer;
  final int _capacity;
  int _head = 0;
  int _size = 0;

  CircularBuffer(this._capacity) : _buffer = List<R?>.filled(_capacity, null);

  /// Adds an element to the buffer.
  void add(R element) {
    _buffer[_head] = element;
    _head = (_head + 1) % _capacity;
    _size = _size < _capacity ? _size + 1 : _size;
  }

  /// Returns the element at the given index (0 is the oldest).
  R operator [](int index) {
    if (index >= _size || index < 0) {
      throw RangeError('Index out of range: $index');
    }
    final bufferIndex = (_head - _size + index) % _capacity;
    return _buffer[bufferIndex] as R;
  }

  /// Returns the current number of elements.
  int get length => _size;

  /// Clears the buffer.
  void clear() {
    _head = 0;
    _size = 0;
    for (int i = 0; i < _capacity; i++) {
      _buffer[i] = null;
    }
  }
}