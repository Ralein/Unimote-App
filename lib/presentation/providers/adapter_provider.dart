import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/adapters/adapter_factory.dart';
import '../../data/storage/device_repository_impl.dart';
import '../../domain/entities/adapter_state.dart';
import '../../domain/entities/device.dart';
import '../../domain/entities/remote_key.dart';
import '../../domain/repositories/remote_adapter.dart';

class AdapterNotifier extends Notifier<AdapterState> {
  RemoteAdapter? _adapter;
  StreamSubscription<AdapterState>? _stateSubscription;
  Device? _currentDevice;
  Device? get currentDevice => _currentDevice;
  final DeviceRepository _deviceRepository = DeviceRepositoryImpl();

  RemoteAdapter? get activeAdapter => _adapter;

  @override
  AdapterState build() {
    ref.onDispose(() {
      _stateSubscription?.cancel();
    });

    _autoConnectSavedDevice();
    return const AdapterState.disconnected();
  }

  Future<void> _autoConnectSavedDevice() async {
    final saved = await _deviceRepository.getSavedDevices();
    if (saved.isNotEmpty) {
      connectToDevice(saved.first);
    }
  }

  Future<void> connectToDevice(Device device) async {
    _stateSubscription?.cancel();
    _currentDevice = device;

    _adapter = AdapterFactory.createAdapter(device);

    _stateSubscription = _adapter!.state.listen((newState) {
      // ignore: avoid_print
      print('[UNIMOTE_STATE] Transitioned to $newState for device ${_currentDevice?.ipAddress}');
      state = newState;
      if (newState.isConnected && _currentDevice != null) {
        _deviceRepository.saveDevice(_currentDevice!);
      }
    });

    await _adapter!.connect(device);
    await Future<void>.delayed(Duration.zero);
  }

  Future<void> sendKey(RemoteKey key) async {
    if (_adapter != null) {
      await _adapter!.sendKey(key);
    }
  }

  Future<void> sendText(String text) async {
    if (_adapter != null) {
      await _adapter!.sendText(text);
    }
  }

  Future<void> launchApp(String appId) async {
    if (_adapter != null) {
      await _adapter!.launchApp(appId);
    }
  }

  Future<void> disconnect() async {
    if (_adapter != null) {
      await _adapter!.disconnect();
      _adapter = null;
    }
    _currentDevice = null;
    state = const AdapterState.disconnected();
  }
}

final adapterNotifierProvider =
    NotifierProvider<AdapterNotifier, AdapterState>(AdapterNotifier.new);

final activeAdapterProvider = Provider<RemoteAdapter?>((ref) {
  return ref.watch(adapterNotifierProvider.notifier).activeAdapter;
});

final adapterStateProvider = StreamProvider<AdapterState>((ref) {
  final adapter = ref.watch(activeAdapterProvider);
  if (adapter == null) return const Stream.empty();
  return adapter.state;
});
