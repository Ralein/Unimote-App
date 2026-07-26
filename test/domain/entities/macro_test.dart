import 'package:flutter_test/flutter_test.dart';
import 'package:unimote/domain/entities/macro.dart';
import 'package:unimote/domain/entities/remote_key.dart';

void main() {
  group('Macro Entity Unit Tests', () {
    test('MacroStep description formats correctly', () {
      const keyStep = MacroStep.key(RemoteKey.power);
      const delayStep = MacroStep.delay(Duration(seconds: 3));
      const appStep = MacroStep.app('netflix');
      const textStep = MacroStep.text('Hello TV');

      expect(keyStep.description, equals('Send Power'));
      expect(delayStep.description, equals('Wait 3s'));
      expect(appStep.description, equals('Launch App "netflix"'));
      expect(textStep.description, equals('Text "Hello TV"'));
    });
  });
}
