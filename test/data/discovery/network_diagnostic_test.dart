import 'package:flutter_test/flutter_test.dart';
import 'package:unimote/data/discovery/network_diagnostic_tool.dart';

void main() {
  group('NetworkDiagnosticTool Unit Tests', () {
    test('portDescriptions maps major TV control ports', () {
      expect(NetworkDiagnosticTool.portDescriptions[8060], contains('Roku'));
      expect(NetworkDiagnosticTool.portDescriptions[8002], contains('Samsung'));
      expect(NetworkDiagnosticTool.portDescriptions[3001], contains('LG'));
      expect(NetworkDiagnosticTool.portDescriptions[7345], contains('Vizio'));
      expect(NetworkDiagnosticTool.portDescriptions[80], contains('Sony'));
      expect(NetworkDiagnosticTool.portDescriptions[6467], contains('Android TV'));
    });
  });
}
