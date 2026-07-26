import 'package:flutter_test/flutter_test.dart';
import 'package:unimote/data/discovery/wake_on_lan_service.dart';

void main() {
  group('WakeOnLanService Unit Tests', () {
    test('createMagicPacket creates 102 byte payload', () {
      const mac = 'AA:BB:CC:DD:EE:FF';
      final packet = WakeOnLanService.createMagicPacket(mac);

      expect(packet.length, equals(102));
      // First 6 bytes are 0xFF
      for (int i = 0; i < 6; i++) {
        expect(packet[i], equals(0xFF));
      }
      // Byte 6 is 0xAA (170), Byte 7 is 0xBB (187)
      expect(packet[6], equals(0xAA));
      expect(packet[7], equals(0xBB));
    });

    test('Throws FormatException on invalid MAC length', () {
      expect(
        () => WakeOnLanService.createMagicPacket('INVALID_MAC'),
        throwsFormatException,
      );
    });
  });
}
