import 'package:flutter_test/flutter_test.dart';
import 'package:unimote/data/adapters/command_queue.dart';

void main() {
  group('CommandQueue Rate-Limiter Tests', () {
    test('Executes enqueued actions sequentially', () async {
      final queue = CommandQueue(minInterval: const Duration(milliseconds: 10));
      final logs = <int>[];

      await Future.wait([
        queue.enqueue(() async => logs.add(1)),
        queue.enqueue(() async => logs.add(2)),
        queue.enqueue(() async => logs.add(3)),
      ]);

      expect(logs, equals([1, 2, 3]));
    });
  });
}
