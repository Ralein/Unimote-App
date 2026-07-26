import 'dart:async';
import 'dart:io';
import '../../domain/entities/device.dart';
import 'device_fingerprinter.dart';

class SubnetScanner {
  static const List<int> targetPorts = [
    8060, // Roku
    8002, // Samsung WSS
    8001, // Samsung WS
    3001, // LG WSS
    3000, // LG WS
    7345, // Vizio HTTPS
    9000, // Vizio HTTP
    80,   // Sony IRCC
    6467, // Android TV TLS
  ];

  Future<String?> getLocalSubnetPrefix() async {
    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLoopback: false,
      );

      for (final interface in interfaces) {
        for (final addr in interface.addresses) {
          if (!addr.isLoopback && !addr.address.startsWith('127.')) {
            final parts = addr.address.split('.');
            if (parts.length == 4) {
              return '${parts[0]}.${parts[1]}.${parts[2]}';
            }
          }
        }
      }
    } catch (_) {}
    return null;
  }

  Stream<Device> scanSubnet({Duration timeoutPerBatch = const Duration(milliseconds: 600)}) async* {
    final prefix = await getLocalSubnetPrefix() ?? '192.168.1';
    final fingerprinter = DeviceFingerprinter();
    final discoveredIps = <String>{};

    // Scan IPs 1..254 in parallel batches of 25 hosts
    for (int start = 1; start <= 254; start += 25) {
      final end = (start + 24) > 254 ? 254 : (start + 24);
      final futures = <Future<Device?>>[];

      for (int host = start; host <= end; host++) {
        final ip = '$prefix.$host';
        futures.add(_probeHost(ip, fingerprinter, timeoutPerBatch));
      }

      final results = await Future.wait(futures);
      for (final device in results) {
        if (device != null && !discoveredIps.contains(device.ipAddress)) {
          discoveredIps.add(device.ipAddress);
          yield device;
        }
      }
    }
  }

  Future<Device?> _probeHost(String ip, DeviceFingerprinter fingerprinter, Duration timeout) async {
    for (final port in targetPorts) {
      try {
        final socket = await Socket.connect(ip, port, timeout: timeout);
        socket.destroy();

        final brand = DeviceFingerprinter.fingerprintFromPort(port);
        final defaultName = '${brand.name.toUpperCase()} (${ip.split('.').last})';

        return Device(
          id: 'subnet-$brand-${ip.replaceAll('.', '-')}',
          name: defaultName,
          brand: brand,
          ipAddress: ip,
          port: port,
        );
      } catch (_) {
        // Port closed or unreachable, try next port
      }
    }
    return null;
  }
}
