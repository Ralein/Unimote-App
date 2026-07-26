import 'package:flutter_test/flutter_test.dart';
import 'package:unimote/data/adapters/androidtv_adapter.dart';
import 'package:unimote/domain/entities/device.dart';

void main() {
  group('AndroidTvAdapter Unit Tests', () {
    test('connect probes target ports 6467 and 5555', () async {
      final adapter = AndroidTvAdapter();
      const device = Device(
        id: 'androidtv-192.168.1.80',
        name: 'Eyeplus Google TV',
        brand: DeviceBrand.androidTv,
        ipAddress: '127.0.0.1',
        port: 6467,
      );

      await adapter.connect(device);
      expect(adapter.activePort, equals(6467));
    });
  });
}
