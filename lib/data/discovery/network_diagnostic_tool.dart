import 'dart:async';
import 'dart:io';
import '../../domain/entities/device.dart';
import 'device_fingerprinter.dart';

class DiagnosticReport {
  final String targetIp;
  final List<int> openPorts;
  final DeviceBrand? detectedBrand;
  final String statusSummary;
  final List<String> recommendations;

  const DiagnosticReport({
    required this.targetIp,
    required this.openPorts,
    required this.detectedBrand,
    required this.statusSummary,
    required this.recommendations,
  });
}

class NetworkDiagnosticTool {
  static const Map<int, String> portDescriptions = {
    8060: 'Roku ECP HTTP REST',
    8002: 'Samsung Tizen Secure WebSocket (WSS)',
    8001: 'Samsung Tizen Plain WebSocket (WS)',
    3001: 'LG webOS Secure WebSocket (WSS)',
    3000: 'LG webOS Plain WebSocket (WS)',
    7345: 'Vizio SmartCast HTTPS API',
    9000: 'Vizio SmartCast HTTP API',
    80:   'Sony Bravia IRCC SOAP REST',
    20060: 'Sony Simple IP Control',
    6467: 'Android TV Google Cast TLS',
    5555: 'Amazon Fire TV ADB Network Shell',
  };

  static Future<DiagnosticReport> diagnose(String targetIp, {Duration socketTimeout = const Duration(milliseconds: 800)}) async {
    final openPorts = <int>[];
    DeviceBrand? detectedBrand;

    final futures = portDescriptions.keys.map((port) async {
      try {
        final socket = await Socket.connect(targetIp, port, timeout: socketTimeout);
        socket.destroy();
        return port;
      } catch (_) {
        return null;
      }
    });

    final results = await Future.wait(futures);
    for (final port in results) {
      if (port != null) {
        openPorts.add(port);
        detectedBrand ??= DeviceFingerprinter.fingerprintFromPort(port);
      }
    }

    final recommendations = <String>[];
    final String summary;

    if (openPorts.isNotEmpty) {
      summary = 'Connected to $targetIp! Found ${openPorts.length} open control port(s): ${openPorts.join(", ")}.';
      if (detectedBrand == DeviceBrand.samsung) {
        recommendations.add('👉 Look at your Samsung TV screen! A pop-up dialog will ask for permission.');
        recommendations.add('👉 Use your TV remote to select "ALLOW" on the TV screen.');
      } else if (detectedBrand == DeviceBrand.lg) {
        recommendations.add('👉 Look at your LG TV screen! Accept the on-screen connection prompt.');
      } else if (detectedBrand == DeviceBrand.vizio) {
        recommendations.add('👉 Vizio TV requires pairing PIN. Enter the 4-digit PIN displayed on TV.');
      } else {
        recommendations.add('👉 Ready to send control commands.');
      }
    } else {
      summary = 'Could not open any TV control ports on $targetIp.';
      recommendations.add('1. Check if the TV is turned ON or in standby mode.');
      recommendations.add('2. Send Wake-on-LAN magic packet to turn on TV.');
      recommendations.add('3. Verify phone and TV are connected to the exact same Wi-Fi network.');
      recommendations.add('4. Check if AP Isolation / Guest Mode is enabled on your Wi-Fi router.');
    }

    return DiagnosticReport(
      targetIp: targetIp,
      openPorts: openPorts,
      detectedBrand: detectedBrand,
      statusSummary: summary,
      recommendations: recommendations,
    );
  }
}
