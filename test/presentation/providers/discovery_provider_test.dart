import 'package:flutter_test/flutter_test.dart';
import 'package:unimote/domain/entities/device.dart';
import 'package:unimote/presentation/providers/discovery_provider.dart';

void main() {
  group('DiscoveryNotifier Unit Tests', () {
    late DiscoveryNotifier notifier;

    setUp(() {
      notifier = DiscoveryNotifier();
    });

    tearDown(() {
      notifier.dispose();
    });

    test('Initial state is not scanning and empty list', () {
      expect(notifier.state.isScanning, isFalse);
      expect(notifier.state.devices, isEmpty);
      expect(notifier.state.selectedDevice, isNull);
    });

    test('addManualDevice adds device and selects it', () async {
      await notifier.addManualDevice('192.168.1.150', brand: DeviceBrand.samsung);

      expect(notifier.state.devices.length, equals(1));
      expect(notifier.state.devices.first.ipAddress, equals('192.168.1.150'));
      expect(notifier.state.devices.first.brand, equals(DeviceBrand.samsung));
      expect(notifier.state.selectedDevice?.ipAddress, equals('192.168.1.150'));
    });

    test('selectDevice updates selectedDevice state', () {
      const device = Device(
        id: 'test-device',
        name: 'Test Device',
        brand: DeviceBrand.roku,
        ipAddress: '192.168.1.200',
        port: 8060,
      );

      notifier.selectDevice(device);
      expect(notifier.state.selectedDevice, equals(device));
    });
  });
}
