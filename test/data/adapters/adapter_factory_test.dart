import 'package:flutter_test/flutter_test.dart';
import 'package:unimote/data/adapters/adapter_factory.dart';
import 'package:unimote/data/adapters/firetv_adapter.dart';
import 'package:unimote/data/adapters/lg_adapter.dart';
import 'package:unimote/data/adapters/mock_adapter.dart';
import 'package:unimote/data/adapters/roku_adapter.dart';
import 'package:unimote/data/adapters/samsung_adapter.dart';
import 'package:unimote/domain/entities/device.dart';

void main() {
  group('AdapterFactory Unit Tests', () {
    test('Instantiates correct adapter for each brand', () {
      const rokuDevice = Device(
        id: 'r1',
        name: 'Roku Express',
        brand: DeviceBrand.roku,
        ipAddress: '192.168.1.10',
        port: 8060,
      );
      const samsungDevice = Device(
        id: 's1',
        name: 'Samsung TV',
        brand: DeviceBrand.samsung,
        ipAddress: '192.168.1.11',
        port: 8002,
      );
      const lgDevice = Device(
        id: 'l1',
        name: 'LG TV',
        brand: DeviceBrand.lg,
        ipAddress: '192.168.1.12',
        port: 3001,
      );
      const fireTvDevice = Device(
        id: 'f1',
        name: 'Fire TV',
        brand: DeviceBrand.fireTv,
        ipAddress: '192.168.1.13',
        port: 5555,
      );
      const mockDevice = Device(
        id: 'm1',
        name: 'Mock TV',
        brand: DeviceBrand.mock,
        ipAddress: '192.168.1.14',
        port: 8080,
      );

      expect(AdapterFactory.createAdapter(rokuDevice), isA<RokuAdapter>());
      expect(AdapterFactory.createAdapter(samsungDevice), isA<SamsungAdapter>());
      expect(AdapterFactory.createAdapter(lgDevice), isA<LgAdapter>());
      expect(AdapterFactory.createAdapter(fireTvDevice), isA<FireTvAdapter>());
      expect(AdapterFactory.createAdapter(mockDevice), isA<MockAdapter>());
    });
  });
}
