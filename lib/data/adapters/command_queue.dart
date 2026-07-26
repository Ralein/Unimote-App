import 'dart:async';

class CommandQueue {
  final Duration minInterval;
  final List<Future<dynamic> Function()> _queue = [];
  bool _isProcessing = false;

  CommandQueue({this.minInterval = const Duration(milliseconds: 100)});

  Future<T> enqueue<T>(Future<T> Function() action) {
    final completer = Completer<T>();

    _queue.add(() async {
      try {
        final result = await action();
        completer.complete(result);
      } catch (e, stack) {
        completer.completeError(e, stack);
      }
    });

    _process();
    return completer.future;
  }

  void _process() async {
    if (_isProcessing || _queue.isEmpty) return;
    _isProcessing = true;

    while (_queue.isNotEmpty) {
      final action = _queue.removeAt(0);
      await action();
      if (_queue.isNotEmpty) {
        await Future.delayed(minInterval);
      }
    }

    _isProcessing = false;
  }
}
