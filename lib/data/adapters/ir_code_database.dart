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
  static const Map<RemoteKey, List<int>> necDefaultCodes = {
    RemoteKey.power: [9000, 4500, 560, 560, 560, 1690, 560, 1690, 560, 560, 560, 560, 560, 1690, 560, 560],
    RemoteKey.volumeUp: [9000, 4500, 560, 1690, 560, 1690, 560, 560, 560, 560, 560, 1690, 560, 560, 560, 560],
    RemoteKey.volumeDown: [9000, 4500, 560, 1690, 560, 560, 560, 1690, 560, 560, 560, 1690, 560, 560, 560, 560],
    RemoteKey.mute: [9000, 4500, 560, 560, 560, 1690, 560, 1690, 560, 1690, 560, 560, 560, 560, 560, 560],
    RemoteKey.home: [9000, 4500, 560, 1690, 560, 1690, 560, 1690, 560, 560, 560, 560, 560, 560, 560, 560],
  };

  static IrCodeSignal getSignal(RemoteKey key, {int frequency = 38000}) {
    final pattern = necDefaultCodes[key] ?? necDefaultCodes[RemoteKey.power]!;
    return IrCodeSignal(frequency: frequency, pattern: pattern);
  }
}
