import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unimote/domain/entities/device.dart';
import 'package:unimote/presentation/providers/discovery_provider.dart';

void main() {
  group('DiscoveryNotifier Unit Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('Initial state is not scanning and empty list', () {
      final state = container.read(discoveryProvider);
      expect(state.isScanning, isFalse);
      expect(state.devices, isEmpty);
      expect(state.selectedDevice, isNull);
    });

    test('addManualDevice adds device and selects it', () async {
      final notifier = container.read(discoveryProvider.notifier);
      await notifier.addManualDevice('192.168.1.150', brand: DeviceBrand.samsung);

      final state = container.read(discoveryProvider);
      expect(state.devices.length, equals(1));
      expect(state.devices.first.ipAddress, equals('192.168.1.150'));
      expect(state.devices.first.brand, equals(DeviceBrand.samsung));
      expect(state.selectedDevice?.ipAddress, equals('192.168.1.150'));
    });

    test('selectDevice updates selectedDevice state', () {
      final notifier = container.read(discoveryProvider.notifier);
      const device = Device(
        id: 'test-device',
        name: 'Test Device',
        brand: DeviceBrand.roku,
        ipAddress: '192.168.1.200',
        port: 8060,
      );

      notifier.selectDevice(device);
      final state = container.read(discoveryProvider);
      expect(state.selectedDevice, equals(device));
    });
  });
}
