import 'package:flutter_test/flutter_test.dart';
import 'package:unimote/data/discovery/ssdp_scanner.dart';

void main() {
  group('SsdpScanner Header Parser Tests', () {
    test('parseHeaders correctly extracts HTTP headers', () {
      const rawSsdp = '''HTTP/1.1 200 OK\r
LOCATION: http://192.168.1.105:8001/ms/1.0/\r
SERVER: SHP, UPnP/1.0, Samsung TP/1.0\r
USN: uuid:12345678-1234-1234-1234-1234567890ab::urn:dial-multiscreen-org:service:dial:1\r
ST: urn:dial-multiscreen-org:service:dial:1\r
MODELNAME: Q70T Series\r
''';

      final headers = SsdpScanner.parseHeaders(rawSsdp);

      expect(headers['LOCATION'], equals('http://192.168.1.105:8001/ms/1.0/'));
      expect(headers['SERVER'], equals('SHP, UPnP/1.0, Samsung TP/1.0'));
      expect(headers['ST'], equals('urn:dial-multiscreen-org:service:dial:1'));
      expect(headers['MODELNAME'], equals('Q70T Series'));
    });
  });
}
