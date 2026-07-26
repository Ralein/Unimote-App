import '../../domain/entities/device.dart';
import 'mdns_scanner.dart';
import 'ssdp_scanner.dart';

class DeviceFingerprinter {
  static Device? fingerprintSsdp(SsdpResponse response) {
    final server = response.server.toLowerCase();
    final location = response.location.toLowerCase();
    final usn = response.usn.toLowerCase();
    final st = response.st.toLowerCase();

    DeviceBrand? brand;
    int port = response.port;
    String name = 'Smart TV';

    if (server.contains('tizen') || server.contains('samsung') || usn.contains('samsung')) {
      brand = DeviceBrand.samsung;
      port = 8002;
      name = _extractNameFromHeader(response, 'Samsung Smart TV');
    } else if (server.contains('webos') || server.contains('lg') || location.contains('webos')) {
      brand = DeviceBrand.lg;
      port = 3001;
      name = _extractNameFromHeader(response, 'LG webOS TV');
    } else if (server.contains('roku') || usn.contains('roku') || st.contains('roku')) {
      brand = DeviceBrand.roku;
      port = 8060;
      name = _extractNameFromHeader(response, 'Roku TV');
    } else if (server.contains('vizio') || location.contains('vizio')) {
      brand = DeviceBrand.vizio;
      port = 7345;
      name = _extractNameFromHeader(response, 'Vizio SmartCast TV');
    } else if (server.contains('sony') || usn.contains('sony') || st.contains('sony')) {
      brand = DeviceBrand.sony;
      port = 20060;
      name = _extractNameFromHeader(response, 'Sony Bravia TV');
    } else if (server.contains('firetv') || server.contains('amazon')) {
      brand = DeviceBrand.fireTv;
      port = 5555;
      name = 'Amazon Fire TV';
    } else if (server.contains('androidtv') || server.contains('googletv')) {
      brand = DeviceBrand.androidTv;
      port = 6467;
      name = 'Android TV';
    }

    if (brand == null) return null;

    final id = '${brand.name}-${response.ipAddress.replaceAll('.', '-')}' ;

    return Device(
      id: id,
      name: name,
      brand: brand,
      ipAddress: response.ipAddress,
      port: port,
    );
  }

  static Device? fingerprintMdns(MdnsResponse response) {
    final service = response.serviceName.toLowerCase();
    final txt = response.txtRecords;

    DeviceBrand? brand;
    int port = response.port;
    String name = txt['fn'] ?? txt['name'] ?? response.hostName.replaceAll('.local', '');

    if (service.contains('_roku-ecp')) {
      brand = DeviceBrand.roku;
      port = 8060;
      if (name.isEmpty || name == response.hostName) name = 'Roku Device';
    } else if (service.contains('_googlecast')) {
      brand = DeviceBrand.androidTv;
      port = 6467;
      name = txt['fn'] ?? 'Chromecast / Google TV';
    } else if (service.contains('_ssap')) {
      brand = DeviceBrand.lg;
      port = 3001;
      name = 'LG webOS TV';
    } else if (service.contains('_airplay')) {
      name = txt['model'] ?? 'Apple TV / AirPlay Device';
      brand = DeviceBrand.androidTv; // Unified media target
    }

    if (brand == null) return null;

    final id = '${brand.name}-${response.ipAddress.replaceAll('.', '-')}';

    return Device(
      id: id,
      name: name,
      brand: brand,
      ipAddress: response.ipAddress,
      port: port,
    );
  }

  static String _extractNameFromHeader(SsdpResponse response, String fallback) {
    final fn = response.headers['FN'] ?? response.headers['FRIENDLYNAME'] ?? response.headers['MODELNAME'];
    if (fn != null && fn.isNotEmpty) {
      return fn;
    }
    return fallback;
  }

  static DeviceBrand fingerprintFromPort(int port) {
    switch (port) {
      case 8060:
        return DeviceBrand.roku;
      case 8002:
      case 8001:
        return DeviceBrand.samsung;
      case 3001:
      case 3000:
        return DeviceBrand.lg;
      case 7345:
      case 9000:
        return DeviceBrand.vizio;
      case 80:
      case 20060:
        return DeviceBrand.sony;
      case 6467:
        return DeviceBrand.androidTv;
      case 5555:
        return DeviceBrand.fireTv;
      default:
        return DeviceBrand.samsung;
    }
  }
}
