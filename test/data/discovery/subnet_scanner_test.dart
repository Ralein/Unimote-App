import 'package:flutter_test/flutter_test.dart';
import 'package:unimote/data/discovery/subnet_scanner.dart';

void main() {
  group('SubnetScanner Unit Tests', () {
    test('targetPorts contains major smart TV ports', () {
      expect(SubnetScanner.targetPorts, contains(8060)); // Roku
      expect(SubnetScanner.targetPorts, contains(8002)); // Samsung WSS
      expect(SubnetScanner.targetPorts, contains(8001)); // Samsung WS
      expect(SubnetScanner.targetPorts, contains(3001)); // LG WSS
      expect(SubnetScanner.targetPorts, contains(3000)); // LG WS
      expect(SubnetScanner.targetPorts, contains(7345)); // Vizio
      expect(SubnetScanner.targetPorts, contains(6467)); // Android TV
    });
  });
}
