import 'package:flutter_test/flutter_test.dart';
import 'package:unimote/data/storage/device_repository_impl.dart';
import 'package:unimote/domain/entities/device.dart';

class MemoryDeviceRepository implements DeviceRepository {
  final Map<String, Device> _storage = {};

  @override
  Future<void> saveDevice(Device device) async {
    _storage[device.id] = device;
  }

  @override
  Future<List<Device>> getSavedDevices() async {
    return _storage.values.toList();
  }

  @override
  Future<void> removeDevice(String id) async {
    _storage.remove(id);
  }
}

void main() {
  group('DeviceRepository Unit Tests', () {
    late DeviceRepository repo;

    setUp(() {
      repo = MemoryDeviceRepository();
    });

    test('saveDevice, getSavedDevices, and removeDevice lifecycle', () async {
      const device = Device(
        id: 'tv-living-room',
        name: 'Living Room TV',
        brand: DeviceBrand.samsung,
        ipAddress: '192.168.1.105',
        port: 8002,
      );

      expect(await repo.getSavedDevices(), isEmpty);

      await repo.saveDevice(device);
      final saved = await repo.getSavedDevices();
      expect(saved.length, equals(1));
      expect(saved.first.name, equals('Living Room TV'));

      await repo.removeDevice('tv-living-room');
      expect(await repo.getSavedDevices(), isEmpty);
    });
  });
}
