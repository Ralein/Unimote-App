import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/discovery/discovery_repository_impl.dart';
import '../../data/discovery/manual_entry.dart';
import '../../domain/entities/device.dart';

class DiscoveryState {
  final bool isScanning;
  final List<Device> devices;
  final Device? selectedDevice;
  final String? errorMessage;

  const DiscoveryState({
    this.isScanning = false,
    this.devices = const [],
    this.selectedDevice,
    this.errorMessage,
  });

  DiscoveryState copyWith({
    bool? isScanning,
    List<Device>? devices,
    Device? selectedDevice,
    String? errorMessage,
  }) {
    return DiscoveryState(
      isScanning: isScanning ?? this.isScanning,
      devices: devices ?? this.devices,
      selectedDevice: selectedDevice ?? this.selectedDevice,
      errorMessage: errorMessage,
    );
  }
}

class DiscoveryNotifier extends Notifier<DiscoveryState> {
  final DiscoveryRepository _repository;
  StreamSubscription<List<Device>>? _scanSubscription;

  DiscoveryNotifier({DiscoveryRepository? repository})
      : _repository = repository ?? DiscoveryRepositoryImpl();

  @override
  DiscoveryState build() {
    ref.onDispose(() {
      _scanSubscription?.cancel();
    });
    return const DiscoveryState();
  }

  void startScan({Duration timeout = const Duration(seconds: 4)}) {
    if (state.isScanning) return;

    state = state.copyWith(isScanning: true, errorMessage: null);

    _scanSubscription?.cancel();
    _scanSubscription = _repository.scan(timeout: timeout).listen(
      (scannedDevices) {
        final currentDevicesMap = {for (var d in state.devices) d.ipAddress: d};
        for (final device in scannedDevices) {
          currentDevicesMap[device.ipAddress] = device;
        }

        state = state.copyWith(
          devices: currentDevicesMap.values.toList(),
        );
      },
      onError: (err) {
        state = state.copyWith(
          isScanning: false,
          errorMessage: 'Scan error: ${err.toString()}',
        );
      },
      onDone: () {
        state = state.copyWith(isScanning: false);
      },
    );
  }

  void stopScan() {
    _scanSubscription?.cancel();
    state = state.copyWith(isScanning: false);
  }

  Future<void> addManualDevice(String ip, {DeviceBrand? brand}) async {
    try {
      final device = await ManualEntryHandler.probeAndCreateDevice(ip, userBrand: brand);
      final updatedList = List<Device>.from(state.devices);

      final index = updatedList.indexWhere((d) => d.ipAddress == device.ipAddress);
      if (index >= 0) {
        updatedList[index] = device;
      } else {
        updatedList.add(device);
      }

      state = state.copyWith(
        devices: updatedList,
        selectedDevice: device,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  void selectDevice(Device device) {
    state = state.copyWith(selectedDevice: device);
  }
}

final discoveryProvider =
    NotifierProvider<DiscoveryNotifier, DiscoveryState>(DiscoveryNotifier.new);
