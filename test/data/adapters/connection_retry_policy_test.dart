import 'package:flutter_test/flutter_test.dart';
import 'package:unimote/data/adapters/connection_retry_policy.dart';

void main() {
  group('ConnectionRetryPolicy Unit Tests', () {
    const policy = ConnectionRetryPolicy(
      maxAttempts: 3,
      initialDelay: Duration(milliseconds: 100),
      maxDelay: Duration(seconds: 1),
    );

    test('Exponential backoff delay calculation', () {
      expect(policy.calculateDelay(1).inMilliseconds, equals(100));
      expect(policy.calculateDelay(2).inMilliseconds, equals(200));
      expect(policy.calculateDelay(3).inMilliseconds, equals(400));
    });

    test('Executes action successfully on first attempt', () async {
      int count = 0;
      final result = await policy.execute(() async {
        count++;
        return 'success';
      });

      expect(result, equals('success'));
      expect(count, equals(1));
    });

    test('Retries failed action up to maxAttempts', () async {
      int count = 0;
      try {
        await policy.execute(() async {
          count++;
          throw Exception('Connection failed');
        });
      } catch (e) {
        expect(e.toString(), contains('Connection failed'));
      }

      expect(count, equals(3));
    });
  });
}
