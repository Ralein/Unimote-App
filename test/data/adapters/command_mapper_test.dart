import 'package:flutter_test/flutter_test.dart';
import 'package:unimote/data/adapters/command_mapper.dart';
import 'package:unimote/domain/entities/remote_key.dart';

void main() {
  group('CommandMapper Unit Tests', () {
    test('RokuCommandMapper maps keys to ECP HTTP endpoints', () {
      final mapper = RokuCommandMapper();

      expect(mapper.mapKey(RemoteKey.home).value, equals('/keypress/Home'));
      expect(mapper.mapKey(RemoteKey.dpadUp).value, equals('/keypress/Up'));
      expect(mapper.mapKey(RemoteKey.select).value, equals('/keypress/Select'));
      expect(mapper.mapKey(RemoteKey.volumeUp).value, equals('/keypress/VolumeUp'));
      expect(mapper.mapKey(RemoteKey.num3).value, equals('/keypress/Lit_3'));
    });

    test('SamsungCommandMapper maps keys to Tizen KEY_ string codes', () {
      final mapper = SamsungCommandMapper();

      expect(mapper.mapKey(RemoteKey.home).value, equals('KEY_HOME'));
      expect(mapper.mapKey(RemoteKey.dpadUp).value, equals('KEY_UP'));
      expect(mapper.mapKey(RemoteKey.select).value, equals('KEY_ENTER'));
      expect(mapper.mapKey(RemoteKey.volumeUp).value, equals('KEY_VOLUP'));
      expect(mapper.mapKey(RemoteKey.back).value, equals('KEY_RETURN'));
    });

    test('LgCommandMapper maps keys to webOS plain string names', () {
      final mapper = LgCommandMapper();

      expect(mapper.mapKey(RemoteKey.home).value, equals('HOME'));
      expect(mapper.mapKey(RemoteKey.dpadUp).value, equals('UP'));
      expect(mapper.mapKey(RemoteKey.select).value, equals('ENTER'));
      expect(mapper.mapKey(RemoteKey.volumeUp).value, equals('VOLUMEUP'));
    });

    test('FireTvCommandMapper maps keys to ADB keycodes', () {
      final mapper = FireTvCommandMapper();

      expect(mapper.mapKey(RemoteKey.home).value, equals('3'));
      expect(mapper.mapKey(RemoteKey.back).value, equals('4'));
      expect(mapper.mapKey(RemoteKey.dpadUp).value, equals('19'));
      expect(mapper.mapKey(RemoteKey.select).value, equals('66'));
    });
  });
}
