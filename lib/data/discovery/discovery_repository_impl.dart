import 'dart:async';
import '../../domain/entities/device.dart';
import 'device_fingerprinter.dart';
import 'mdns_scanner.dart';
import 'ssdp_scanner.dart';

abstract class DiscoveryRepository {
  Stream<List<Device>> scan({Duration timeout = const Duration(seconds: 4)});
}

class DiscoveryRepositoryImpl implements DiscoveryRepository {
  final SsdpScanner ssdpScanner;
  final MdnsScanner mdnsScanner;

  DiscoveryRepositoryImpl({
    SsdpScanner? ssdpScanner,
    MdnsScanner? mdnsScanner,
  })  : ssdpScanner = ssdpScanner ?? SsdpScanner(),
        mdnsScanner = mdnsScanner ?? MdnsScanner();

  @override
  Stream<List<Device>> scan({Duration timeout = const Duration(seconds: 4)}) async* {
    final Map<String, Device> discovered = {};
    final controller = StreamController<List<Device>>();

    final ssdpSub = ssdpScanner.scan(timeout: timeout).listen((ssdpResp) {
      final device = DeviceFingerprinter.fingerprintSsdp(ssdpResp);
      if (device != null) {
        discovered[device.ipAddress] = device;
        controller.add(discovered.values.toList());
      }
    });

    final mdnsSub = mdnsScanner.scan(timeout: timeout).listen((mdnsResp) {
      final device = DeviceFingerprinter.fingerprintMdns(mdnsResp);
      if (device != null) {
        if (!discovered.containsKey(device.ipAddress)) {
          discovered[device.ipAddress] = device;
          controller.add(discovered.values.toList());
        }
      }
    });

    final stopWatch = Stopwatch()..start();
    while (stopWatch.elapsed < timeout) {
      await Future.delayed(const Duration(milliseconds: 100));
      yield discovered.values.toList();
    }

    await ssdpSub.cancel();
    await mdnsSub.cancel();
    await controller.close();
  }
}
