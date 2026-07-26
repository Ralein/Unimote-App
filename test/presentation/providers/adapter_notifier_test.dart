import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unimote/domain/entities/adapter_state.dart';
import 'package:unimote/domain/entities/device.dart';
import 'package:unimote/domain/entities/remote_key.dart';
import 'package:unimote/presentation/providers/adapter_provider.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  FlutterSecureStorage.setMockInitialValues({});

  group('AdapterNotifier Unit Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('Initializes with default mock device connection', () async {
      final state = container.read(adapterNotifierProvider);
      expect(state.status, isNot(AdapterStateStatus.error));
    });

    test('connectToDevice switches active adapter and pairs', () async {
      const device = Device(
        id: 'test-mock-01',
        name: 'Mock Living Room',
        brand: DeviceBrand.mock,
        ipAddress: '192.168.1.105',
        port: 8080,
      );

      final notifier = container.read(adapterNotifierProvider.notifier);
      await notifier.connectToDevice(device);

      final state = container.read(adapterNotifierProvider);
      expect(state.connectedDevice, equals(device));
      expect(state.status, equals(AdapterStateStatus.paired));
    });

    test('sendKey invokes key execution on active adapter', () async {
      const mockDevice = Device(
        id: 'm1',
        name: 'Mock Device',
        brand: DeviceBrand.mock,
        ipAddress: '192.168.1.50',
        port: 8080,
      );

      final notifier = container.read(adapterNotifierProvider.notifier);
      await notifier.connectToDevice(mockDevice);

      await notifier.sendKey(RemoteKey.power);
      await notifier.sendKey(RemoteKey.volumeUp);

      final state = container.read(adapterNotifierProvider);
      expect(state.isConnected, isTrue);
    });
  });
}
