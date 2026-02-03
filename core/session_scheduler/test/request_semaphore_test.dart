import 'package:flutter_test/flutter_test.dart';
import 'package:session_scheduler/session_scheduler.dart';

void main() {
  group('RequestSemaphore', () {
    test('allows concurrent requests up to max', () async {
      final semaphore = RequestSemaphore(maxConcurrent: 2);
      
      expect(semaphore.maxConcurrent, equals(2));
      expect(semaphore.current, equals(0));
      expect(semaphore.waiting, equals(0));
    });

    test('executes operation and releases slot', () async {
      final semaphore = RequestSemaphore(maxConcurrent: 1);
      
      final result = await semaphore.acquire(() async => 42);
      
      expect(result, equals(42));
      expect(semaphore.current, equals(0));
    });

    test('queues operations when max concurrent reached', () async {
      final semaphore = RequestSemaphore(maxConcurrent: 1);
      
      // Start an operation that takes time
      final future1 = semaphore.acquire(() async {
        await Future<void>.delayed(const Duration(milliseconds: 50));
        return 1;
      });
      
      // Immediately start another - should be queued
      final future2 = semaphore.acquire(() async => 2);
      
      expect(semaphore.waiting, equals(1));
      
      final results = await Future.wait([future1, future2]);
      
      expect(results, equals([1, 2]));
      expect(semaphore.current, equals(0));
      expect(semaphore.waiting, equals(0));
    });

    test('releases slot even on exception', () async {
      final semaphore = RequestSemaphore(maxConcurrent: 1);
      
      // Execute operation that throws and wait for it to complete
      var exceptionThrown = false;
      try {
        await semaphore.acquire(() async => throw Exception('test'));
      } catch (_) {
        exceptionThrown = true;
      }
      expect(exceptionThrown, isTrue);
      
      // Give time for the slot to be released
      await Future<void>.delayed(Duration.zero);
      
      // Slot should be released after exception
      expect(semaphore.current, equals(0));
      
      // Should be able to execute another operation
      final result = await semaphore.acquire(() async => 'success');
      expect(result, equals('success'));
    });
  });
}