import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../domain/entities/device.dart';

abstract class DeviceRepository {
  Future<void> saveDevice(Device device);
  Future<List<Device>> getSavedDevices();
  Future<void> removeDevice(String id);
}

class DeviceRepositoryImpl implements DeviceRepository {
  final FlutterSecureStorage _storage;
  static const String _storageKey = 'saved_unimote_devices';

  DeviceRepositoryImpl({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  @override
  Future<void> saveDevice(Device device) async {
    final devices = await getSavedDevices();
    final index = devices.indexWhere((d) => d.id == device.id || d.ipAddress == device.ipAddress);
    if (index >= 0) {
      devices[index] = device;
    } else {
      devices.add(device);
    }

    final jsonList = devices.map((d) => _toJson(d)).toList();
    await _storage.write(key: _storageKey, value: jsonEncode(jsonList));
  }

  @override
  Future<List<Device>> getSavedDevices() async {
    try {
      final raw = await _storage.read(key: _storageKey);
      if (raw == null || raw.isEmpty) return [];
      final List<dynamic> jsonList = jsonDecode(raw);
      return jsonList.map((j) => _fromJson(j as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> removeDevice(String id) async {
    final devices = await getSavedDevices();
    devices.removeWhere((d) => d.id == id);
    final jsonList = devices.map((d) => _toJson(d)).toList();
    await _storage.write(key: _storageKey, value: jsonEncode(jsonList));
  }

  Map<String, dynamic> _toJson(Device device) {
    return {
      'id': device.id,
      'name': device.name,
      'brand': device.brand.name,
      'ipAddress': device.ipAddress,
      'macAddress': device.macAddress,
      'port': device.port,
      'pairedToken': device.pairedToken,
    };
  }

  Device _fromJson(Map<String, dynamic> json) {
    return Device(
      id: json['id'] as String,
      name: json['name'] as String,
      brand: DeviceBrand.values.firstWhere(
        (b) => b.name == json['brand'],
        orElse: () => DeviceBrand.samsung,
      ),
      ipAddress: json['ipAddress'] as String,
      macAddress: json['macAddress'] as String?,
      port: json['port'] as int,
      pairedToken: json['pairedToken'] as String?,
    );
  }
}
