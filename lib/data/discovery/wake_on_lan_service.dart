import 'dart:io';

class WakeOnLanService {
  static List<int> createMagicPacket(String macAddress) {
    final cleanMac = macAddress.replaceAll(RegExp(r'[^0-9A-Fa-f]'), '');
    if (cleanMac.length != 12) {
      throw const FormatException('MAC address must contain exactly 12 hex digits (e.g. AA:BB:CC:DD:EE:FF)');
    }

    final macBytes = <int>[];
    for (int i = 0; i < 12; i += 2) {
      macBytes.add(int.parse(cleanMac.substring(i, i + 2), radix: 16));
    }

    final packet = <int>[];
    // 6 bytes of 0xFF
    for (int i = 0; i < 6; i++) {
      packet.add(0xFF);
    }
    // 16 repetitions of target MAC address
    for (int i = 0; i < 16; i++) {
      packet.addAll(macBytes);
    }

    return packet;
  }

  static Future<bool> sendWakeOnLan(String macAddress, {List<int> ports = const [9, 7]}) async {
    try {
      final packet = createMagicPacket(macAddress);
      final socket = await RawDatagramSocket.bind(
        InternetAddress.anyIPv4,
        0,
        reuseAddress: true,
        reusePort: false,
      );
      socket.broadcastEnabled = true;

      final broadcastAddr = InternetAddress('255.255.255.255');
      for (final port in ports) {
        socket.send(packet, broadcastAddr, port);
      }

      socket.close();
      return true;
    } catch (_) {
      return false;
    }
  }
}
