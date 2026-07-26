import '../../domain/entities/remote_key.dart';

class IrCodeSignal {
  final int frequency;
  final List<int> pattern;

  const IrCodeSignal({
    this.frequency = 38000,
    required this.pattern,
  });
}

class IrCodeDatabase {
  static const int necCarrierHz = 38000;
  static const int sonyCarrierHz = 40000;

  /// Generates a 32-bit NEC protocol pattern in microseconds for ConsumerIrManager.
  static List<int> buildNecPattern(int hexCode) {
    final pattern = <int>[];
    // Leader pulse: 9000µs ON, 4500µs OFF
    pattern.add(9000);
    pattern.add(4500);

    // 32-bit data stream
    for (int i = 31; i >= 0; i--) {
      final bit = (hexCode >> i) & 1;
      pattern.add(560); // Mark
      if (bit == 1) {
        pattern.add(1690); // Space for bit 1
      } else {
        pattern.add(560); // Space for bit 0
      }
    }

    // Stop bit
    pattern.add(560);
    return pattern;
  }

  /// Generates a 12-bit Sony SIRC protocol pattern in microseconds for ConsumerIrManager.
  static List<int> buildSonyPattern(int command, int address) {
    final pattern = <int>[];
    // Header: 2400µs ON, 600µs OFF
    pattern.add(2400);
    pattern.add(600);

    // 7-bit command
    for (int i = 0; i < 7; i++) {
      final bit = (command >> i) & 1;
      pattern.add(bit == 1 ? 1200 : 600);
      pattern.add(600);
    }

    // 5-bit address
    for (int i = 0; i < 5; i++) {
      final bit = (address >> i) & 1;
      pattern.add(bit == 1 ? 1200 : 600);
      pattern.add(600);
    }

    return pattern;
  }

  static const Map<RemoteKey, int> necKeyCodes = {
    RemoteKey.power: 0x00FF40BF,
    RemoteKey.volumeUp: 0x00FF00FF,
    RemoteKey.volumeDown: 0x00FF807F,
    RemoteKey.mute: 0x00FF14EB,
    RemoteKey.dpadUp: 0x00FF629D,
    RemoteKey.dpadDown: 0x00FFA857,
    RemoteKey.dpadLeft: 0x00FF22DD,
    RemoteKey.dpadRight: 0x00FFC23D,
    RemoteKey.select: 0x00FF02FD,
    RemoteKey.home: 0x00FF6897,
    RemoteKey.back: 0x00FF9867,
    RemoteKey.inputSource: 0x00FF38C7,
    RemoteKey.channelUp: 0x00FF48B7,
    RemoteKey.channelDown: 0x00FF08F7,
    RemoteKey.digit0: 0x00FF6897,
    RemoteKey.digit1: 0x00FF30CF,
    RemoteKey.digit2: 0x00FF18E7,
    RemoteKey.digit3: 0x00FF7A85,
    RemoteKey.digit4: 0x00FF10EF,
    RemoteKey.digit5: 0x00FF38C7,
    RemoteKey.digit6: 0x00FF5AA5,
    RemoteKey.digit7: 0x00FF42BD,
    RemoteKey.digit8: 0x00FF4AB5,
    RemoteKey.digit9: 0x00FF52AD,
  };

  static IrCodeSignal getSignal(RemoteKey key, {int frequency = necCarrierHz}) {
    final hexCode = necKeyCodes[key] ?? necKeyCodes[RemoteKey.power]!;
    final pattern = buildNecPattern(hexCode);
    return IrCodeSignal(frequency: frequency, pattern: pattern);
  }
}
