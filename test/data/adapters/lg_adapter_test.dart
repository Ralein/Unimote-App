import 'package:flutter_test/flutter_test.dart';
import 'package:unimote/data/adapters/lg_adapter.dart';

void main() {
  group('LgAdapter Unit Tests', () {
    test('buildRegisterPayload creates valid SSAP registration frame', () {
      final payloadWithoutKey = LgAdapter.buildRegisterPayload();

      expect(payloadWithoutKey['type'], equals('register'));
      expect(payloadWithoutKey['id'], equals('register_0'));
      final manifest = (payloadWithoutKey['payload'] as Map<String, dynamic>)['manifest'];
      expect(manifest['permissions'], contains('CONTROL_POWER'));
      expect(manifest['permissions'], contains('CONTROL_INPUT_TEXT'));

      final payloadWithKey = LgAdapter.buildRegisterPayload(clientKey: 'lg_key_999');
      final innerPayload = payloadWithKey['payload'] as Map<String, dynamic>;
      expect(innerPayload['client-key'], equals('lg_key_999'));
    });
  });
}
