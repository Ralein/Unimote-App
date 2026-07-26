import 'package:flutter_test/flutter_test.dart';
import 'package:unimote/data/adapters/firetv_adapter.dart';
import 'package:unimote/domain/entities/device.dart';

void main() {
  group('FireTvAdapter Unit Tests', () {
    test('connect probes target ports 5555 and 6467', () async {
      final adapter = FireTvAdapter();
      const device = Device(
        id: 'firetv-192.168.1.50',
        name: 'Living Room Fire TV',
        brand: DeviceBrand.fireTv,
        ipAddress: '127.0.0.1',
        port: 5555,
      );

      await adapter.connect(device);
      expect(adapter.activePort, equals(5555));
    });
  });
}
