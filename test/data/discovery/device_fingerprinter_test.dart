import 'package:flutter_test/flutter_test.dart';
import 'package:unimote/data/discovery/device_fingerprinter.dart';
import 'package:unimote/data/discovery/ssdp_scanner.dart';
import 'package:unimote/domain/entities/device.dart';

void main() {
  group('DeviceFingerprinter Unit Tests', () {
    test('Fingerprints Samsung Tizen TV from SSDP', () {
      const resp = SsdpResponse(
        ipAddress: '192.168.1.105',
        port: 1900,
        location: 'http://192.168.1.105:8001/',
        server: 'Samsung Tizen OS 6.0',
        usn: 'uuid:samsung-123',
        st: 'ssdp:all',
        headers: {'MODELNAME': 'Samsung 55 QLED'},
      );

      final device = DeviceFingerprinter.fingerprintSsdp(resp);

      expect(device, isNotNull);
      expect(device!.brand, equals(DeviceBrand.samsung));
      expect(device.port, equals(8002));
      expect(device.ipAddress, equals('192.168.1.105'));
    });

    test('Fingerprints LG webOS TV from SSDP', () {
      const resp = SsdpResponse(
        ipAddress: '192.168.1.112',
        port: 1900,
        location: 'http://192.168.1.112:3000/udap/api/',
        server: 'webOS/5.0 UPnP/1.0',
        usn: 'uuid:lg-webos-456',
        st: 'ssdp:all',
        headers: {},
      );

      final device = DeviceFingerprinter.fingerprintSsdp(resp);

      expect(device, isNotNull);
      expect(device!.brand, equals(DeviceBrand.lg));
      expect(device.port, equals(3001));
    });

    test('Fingerprints Roku device from SSDP', () {
      const resp = SsdpResponse(
        ipAddress: '192.168.1.120',
        port: 1900,
        location: 'http://192.168.1.120:8060/',
        server: 'Roku/10.5.0 UPnP/1.0',
        usn: 'uuid:roku:ecp:123',
        st: 'roku:ecp',
        headers: {},
      );

      final device = DeviceFingerprinter.fingerprintSsdp(resp);

      expect(device, isNotNull);
      expect(device!.brand, equals(DeviceBrand.roku));
      expect(device.port, equals(8060));
    });
  });
}
