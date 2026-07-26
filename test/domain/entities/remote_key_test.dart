import 'package:flutter_test/flutter_test.dart';
import 'package:unimote/domain/entities/remote_key.dart';

void main() {
  group('RemoteKey Enum Tests', () {
    test('isNumeric returns true only for num0 through num9', () {
      expect(RemoteKey.num0.isNumeric, isTrue);
      expect(RemoteKey.num5.isNumeric, isTrue);
      expect(RemoteKey.num9.isNumeric, isTrue);

      expect(RemoteKey.power.isNumeric, isFalse);
      expect(RemoteKey.volumeUp.isNumeric, isFalse);
      expect(RemoteKey.home.isNumeric, isFalse);
    });

    test('displayName returns readable strings', () {
      expect(RemoteKey.power.displayName, 'Power');
      expect(RemoteKey.dpadUp.displayName, 'Up');
      expect(RemoteKey.volumeUp.displayName, 'Vol +');
      expect(RemoteKey.num7.displayName, '7');
    });
  });
}
