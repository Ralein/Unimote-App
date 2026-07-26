import 'package:flutter_test/flutter_test.dart';
import 'package:unimote/data/adapters/mock_adapter.dart';
import 'package:unimote/domain/entities/adapter_state.dart';
import 'package:unimote/domain/entities/device.dart';
import 'package:unimote/domain/entities/remote_key.dart';

void main() {
  group('MockAdapter Unit Tests', () {
    late MockAdapter adapter;
    const testDevice = Device(
      id: 'test-01',
      name: 'Test TV',
      brand: DeviceBrand.mock,
      ipAddress: '192.168.1.50',
      port: 8080,
    );

    setUp(() {
      adapter = MockAdapter();
    });

    tearDown(() {
      adapter.dispose();
    });

    test('Initial state is disconnected', () {
      expect(adapter.currentState.status, AdapterStateStatus.disconnected);
    });

    test('connect() transitions state to connecting then paired', () async {
      final states = <AdapterStateStatus>[];
      final subscription = adapter.state.listen((s) => states.add(s.status));

      await adapter.connect(testDevice);
      await Future<void>.delayed(Duration.zero);

      expect(states, containsAllInOrder([
        AdapterStateStatus.connecting,
        AdapterStateStatus.paired,
      ]));
      expect(adapter.currentState.connectedDevice, equals(testDevice));

      await subscription.cancel();
    });

    test('sendKey, sendText, launchApp append to logs', () async {
      await adapter.sendKey(RemoteKey.power);
      await adapter.sendKey(RemoteKey.volumeUp);
      await adapter.sendText('Hello TV');
      await adapter.launchApp('com.netflix.ninja');

      expect(adapter.keyLogs, equals([RemoteKey.power, RemoteKey.volumeUp]));
      expect(adapter.textLogs, equals(['Hello TV']));
      expect(adapter.appLogs, equals(['com.netflix.ninja']));
    });

    test('disconnect() sets state back to disconnected', () async {
      await adapter.connect(testDevice);
      expect(adapter.currentState.status, AdapterStateStatus.paired);

      await adapter.disconnect();
      expect(adapter.currentState.status, AdapterStateStatus.disconnected);
    });
  });
}
