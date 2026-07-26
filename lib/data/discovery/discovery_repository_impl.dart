import 'dart:async';
import '../../domain/entities/device.dart';
import 'device_fingerprinter.dart';
import 'mdns_scanner.dart';
import 'ssdp_scanner.dart';
import 'subnet_scanner.dart';

abstract class DiscoveryRepository {
  Stream<List<Device>> scan({Duration timeout = const Duration(seconds: 4)});
}

class DiscoveryRepositoryImpl implements DiscoveryRepository {
  final SsdpScanner ssdpScanner;
  final MdnsScanner mdnsScanner;
  final SubnetScanner subnetScanner;

  DiscoveryRepositoryImpl({
    SsdpScanner? ssdpScanner,
    MdnsScanner? mdnsScanner,
    SubnetScanner? subnetScanner,
  })  : ssdpScanner = ssdpScanner ?? SsdpScanner(),
        mdnsScanner = mdnsScanner ?? MdnsScanner(),
        subnetScanner = subnetScanner ?? SubnetScanner();

  @override
  Stream<List<Device>> scan({Duration timeout = const Duration(seconds: 4)}) {
    late StreamController<List<Device>> controller;
    final Map<String, Device> discovered = {};
    StreamSubscription? ssdpSub;
    StreamSubscription? mdnsSub;
    StreamSubscription? subnetSub;
    Timer? timer;

    controller = StreamController<List<Device>>(
      onListen: () {
        ssdpSub = ssdpScanner.scan(timeout: timeout).listen((ssdpResp) {
          final device = DeviceFingerprinter.fingerprintSsdp(ssdpResp);
          if (device != null && !controller.isClosed) {
            discovered[device.ipAddress] = device;
            controller.add(discovered.values.toList());
          }
        });

        mdnsSub = mdnsScanner.scan(timeout: timeout).listen((mdnsResp) {
          final device = DeviceFingerprinter.fingerprintMdns(mdnsResp);
          if (device != null && !controller.isClosed) {
            if (!discovered.containsKey(device.ipAddress)) {
              discovered[device.ipAddress] = device;
              controller.add(discovered.values.toList());
            }
          }
        });

        subnetSub = subnetScanner.scanSubnet().listen((device) {
          if (!controller.isClosed) {
            if (!discovered.containsKey(device.ipAddress)) {
              discovered[device.ipAddress] = device;
              controller.add(discovered.values.toList());
            }
          }
        });

        timer = Timer(timeout, () {
          if (!controller.isClosed) {
            controller.close();
          }
        });
      },
      onCancel: () async {
        timer?.cancel();
        await ssdpSub?.cancel();
        await mdnsSub?.cancel();
        await subnetSub?.cancel();
        if (!controller.isClosed) {
          await controller.close();
        }
      },
    );

    return controller.stream;
  }
}
