import 'dart:async';
import 'dart:io';
import '../../domain/entities/device.dart';

class ManualEntryHandler {
  static bool isValidIpv4(String ip) {
    final regExp = RegExp(
      r'^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$',
    );
    return regExp.hasMatch(ip.trim());
  }

  static Future<Device> probeAndCreateDevice(
    String ipAddress, {
    DeviceBrand? userBrand,
  }) async {
    final cleanIp = ipAddress.trim();
    if (!isValidIpv4(cleanIp)) {
      throw const FormatException('Invalid IPv4 address format');
    }

    if (userBrand != null) {
      return Device(
        id: 'manual-${userBrand.name}-$cleanIp',
        name: '${_brandDisplayName(userBrand)} ($cleanIp)',
        brand: userBrand,
        ipAddress: cleanIp,
        port: _defaultPortForBrand(userBrand),
      );
    }

    // Auto port probe for protocol detection
    final Map<int, DeviceBrand> portBrandMap = {
      8060: DeviceBrand.roku,
      8002: DeviceBrand.samsung,
      3001: DeviceBrand.lg,
      7345: DeviceBrand.vizio,
      5555: DeviceBrand.fireTv,
      6467: DeviceBrand.androidTv,
      20060: DeviceBrand.sony,
    };

    for (final entry in portBrandMap.entries) {
      try {
        final socket = await Socket.connect(
          cleanIp,
          entry.key,
          timeout: const Duration(milliseconds: 600),
        );
        socket.destroy();
        return Device(
          id: 'manual-${entry.value.name}-$cleanIp',
          name: '${_brandDisplayName(entry.value)} ($cleanIp)',
          brand: entry.value,
          ipAddress: cleanIp,
          port: entry.key,
        );
      } catch (_) {}
    }

    // Fallback to Roku HTTP or Samsung default port if probing un-responsive
    return Device(
      id: 'manual-generic-$cleanIp',
      name: 'Smart TV ($cleanIp)',
      brand: DeviceBrand.samsung,
      ipAddress: cleanIp,
      port: 8002,
    );
  }

  static String _brandDisplayName(DeviceBrand brand) {
    switch (brand) {
      case DeviceBrand.samsung:
        return 'Samsung TV';
      case DeviceBrand.lg:
        return 'LG webOS TV';
      case DeviceBrand.roku:
        return 'Roku TV';
      case DeviceBrand.fireTv:
        return 'Fire TV';
      case DeviceBrand.androidTv:
        return 'Android TV';
      case DeviceBrand.vizio:
        return 'Vizio SmartCast';
      case DeviceBrand.sony:
        return 'Sony Bravia';
      case DeviceBrand.genericIr:
        return 'IR Legacy TV';
      case DeviceBrand.mock:
        return 'Mock TV';
    }
  }

  static int _defaultPortForBrand(DeviceBrand brand) {
    switch (brand) {
      case DeviceBrand.samsung:
        return 8002;
      case DeviceBrand.lg:
        return 3001;
      case DeviceBrand.roku:
        return 8060;
      case DeviceBrand.fireTv:
        return 5555;
      case DeviceBrand.androidTv:
        return 6467;
      case DeviceBrand.vizio:
        return 7345;
      case DeviceBrand.sony:
        return 20060;
      default:
        return 8080;
    }
  }
}
