import 'dart:async';
import 'dart:math' as math;

/// {@template request_semaphore}
/// Global semaphore for controlling concurrent LLM requests.
/// 
/// Limits the number of simultaneous requests across all sessions.
/// This is a singleton that should be shared across the application.
/// {@endtemplate}
final class RequestSemaphore {
  /// {@macro request_semaphore}
  RequestSemaphore({required int maxConcurrent})
      : _maxConcurrent = maxConcurrent,
        assert(maxConcurrent >= 1, 'maxConcurrent must be at least 1');

  final int _maxConcurrent;
  int _current = 0;
  final _queue = <Completer<void>>[];

  /// Executes an operation with semaphore control.
  /// 
  /// If the semaphore is full, waits until a slot is available.
  /// Releases the slot after the operation completes (success or failure).
  Future<T> acquire<T>(Future<T> Function() operation) async {
    await _acquireSlot();
    try {
      return await operation();
    } finally {
      _releaseSlot();
    }
  }

  Future<void> _acquireSlot() async {
    if (_current < _maxConcurrent) {
      _current++;
      return;
    }

    final completer = Completer<void>();
    _queue.add(completer);
    await completer.future;
  }

  void _releaseSlot() {
    if (_queue.isNotEmpty) {
      final next = _queue.removeAt(0);
      next.complete();
    } else {
      _current = math.max(0, _current - 1);
    }
  }

  /// Current number of acquired slots.
  int get current => _current;

  /// Maximum number of concurrent slots.
  int get maxConcurrent => _maxConcurrent;

  /// Number of operations waiting in queue.
  int get waiting => _queue.length;
}