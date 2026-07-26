import 'package:flutter_test/flutter_test.dart';
import 'package:unimote/data/adapters/samsung_adapter.dart';

void main() {
  group('SamsungAdapter Unit Tests', () {
    test('encodeAppName encodes app name to base64', () {
      final base64Name = SamsungAdapter.encodeAppName('Unimote');
      expect(base64Name, equals('VW5pbW90ZQ=='));
    });

    test('buildUrl formats secure wss URL with app name and token', () {
      final urlWithoutToken = SamsungAdapter.buildUrl(
        ip: '192.168.1.105',
        port: 8002,
        appName: 'Unimote',
      );
      expect(
        urlWithoutToken,
        equals('wss://192.168.1.105:8002/api/v2/channels/samsung.remote.control?name=VW5pbW90ZQ=='),
      );

      final urlWithToken = SamsungAdapter.buildUrl(
        ip: '192.168.1.105',
        port: 8002,
        appName: 'Unimote',
        token: '12345678',
      );
      expect(
        urlWithToken,
        equals('wss://192.168.1.105:8002/api/v2/channels/samsung.remote.control?name=VW5pbW90ZQ==&token=12345678'),
      );
    });

    test('buildUrl formats unencrypted ws URL for port 8001', () {
      final url = SamsungAdapter.buildUrl(
        ip: '192.168.1.105',
        port: 8001,
        appName: 'Unimote',
      );
      expect(
        url,
        equals('ws://192.168.1.105:8001/api/v2/channels/samsung.remote.control?name=VW5pbW90ZQ=='),
      );
    });
  });
}
