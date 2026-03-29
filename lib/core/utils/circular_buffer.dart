class CircularBuffer<T> {
  final int capacity;
  final List<T?> _buffer;
  int _head = 0;
  int _tail = 0;
  bool _isFull = false;

  CircularBuffer(this.capacity) : _buffer = List<T?>.filled(capacity, null);

  void add(T item) {
    _buffer[_target] = item;
    
    if (_isFull) {
      _tail = (_tail + 1) % capacity;
    }
    
    _head = (_head + 1) % capacity;
    _isFull = _head == _tail;
  }
  
  int get _target => _isFull ? _tail : _head;

  List<T> get toList {
    List<T> result = [];
    if (_isFull) {
      for (int i = 0; i < capacity; i++) {
        result.add(_buffer[(_tail + i) % capacity] as T);
      }
    } else {
      for (int i = 0; i < _head; i++) {
        result.add(_buffer[i] as T);
      }
    }
    return result;
  }

  void clear() {
    _head = 0;
    _tail = 0;
    _isFull = false;
  }

  int get length => _isFull ? capacity : _head;
}
