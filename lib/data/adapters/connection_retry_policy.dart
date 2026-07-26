import 'dart:async';
import 'dart:math';

class ConnectionRetryPolicy {
  final int maxAttempts;
  final Duration initialDelay;
  final Duration maxDelay;

  const ConnectionRetryPolicy({
    this.maxAttempts = 3,
    this.initialDelay = const Duration(milliseconds: 500),
    this.maxDelay = const Duration(seconds: 10),
  });

  Duration calculateDelay(int attempt) {
    if (attempt <= 1) return initialDelay;
    final delayMs = initialDelay.inMilliseconds * pow(2, attempt - 1);
    final cappedMs = min(maxDelay.inMilliseconds, delayMs.round());
    return Duration(milliseconds: cappedMs);
  }

  Future<T> execute<T>(Future<T> Function() action) async {
    int attempt = 1;
    while (true) {
      try {
        return await action();
      } catch (error) {
        if (attempt >= maxAttempts) {
          rethrow;
        }
        final delay = calculateDelay(attempt);
        await Future.delayed(delay);
        attempt++;
      }
    }
  }
}
