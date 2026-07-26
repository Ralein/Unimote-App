import 'package:flutter_test/flutter_test.dart';
import 'package:unimote/data/adapters/bluetooth_adapter.dart';
import 'package:unimote/domain/entities/remote_key.dart';

void main() {
  group('BluetoothAdapter Unit Tests', () {
    test('keyToHidCodeMap contains valid HID codes for all essential remote keys', () {
      expect(BluetoothAdapter.keyToHidCodeMap[RemoteKey.power], equals(0x0030));
      expect(BluetoothAdapter.keyToHidCodeMap[RemoteKey.home], equals(0x0223));
      expect(BluetoothAdapter.keyToHidCodeMap[RemoteKey.back], equals(0x0224));
      expect(BluetoothAdapter.keyToHidCodeMap[RemoteKey.select], equals(0x0041));
      expect(BluetoothAdapter.keyToHidCodeMap[RemoteKey.volumeUp], equals(0x00E9));
      expect(BluetoothAdapter.keyToHidCodeMap[RemoteKey.volumeDown], equals(0x00EA));
      expect(BluetoothAdapter.keyToHidCodeMap[RemoteKey.mute], equals(0x00E2));
    });
  });
}
