import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/adapters/adapter_factory.dart';
import '../../data/adapters/mock_adapter.dart';
import '../../domain/entities/adapter_state.dart';
import '../../domain/entities/device.dart';
import '../../domain/entities/remote_key.dart';
import '../../domain/repositories/remote_adapter.dart';

final mockDevice = const Device(
  id: 'mock-tv-01',
  name: 'Living Room TV (Mock)',
  brand: DeviceBrand.mock,
  ipAddress: '192.168.1.100',
  port: 8080,
);

class AdapterNotifier extends Notifier<AdapterState> {
  RemoteAdapter? _adapter;
  StreamSubscription<AdapterState>? _stateSubscription;
  Device? _currentDevice;

  RemoteAdapter get activeAdapter => _adapter ?? _fallbackMockAdapter;
  late final MockAdapter _fallbackMockAdapter = MockAdapter();

  @override
  AdapterState build() {
    ref.onDispose(() {
      _stateSubscription?.cancel();
      _fallbackMockAdapter.dispose();
    });

    // Default to connecting mock device on app start
    Future.microtask(() => connectToDevice(mockDevice));

    return const AdapterState.disconnected();
  }

  Future<void> connectToDevice(Device device) async {
    if (_currentDevice == device && state.isConnected) return;

    _stateSubscription?.cancel();
    _currentDevice = device;

    _adapter = AdapterFactory.createAdapter(device);

    _stateSubscription = _adapter!.state.listen((newState) {
      state = newState;
    });

    await _adapter!.connect(device);
  }

  Future<void> sendKey(RemoteKey key) async {
    await activeAdapter.sendKey(key);
  }

  Future<void> sendText(String text) async {
    await activeAdapter.sendText(text);
  }

  Future<void> launchApp(String appId) async {
    await activeAdapter.launchApp(appId);
  }

  Future<void> disconnect() async {
    if (_adapter != null) {
      await _adapter!.disconnect();
    }
  }
}

final adapterNotifierProvider =
    NotifierProvider<AdapterNotifier, AdapterState>(AdapterNotifier.new);

final activeAdapterProvider = Provider<RemoteAdapter>((ref) {
  return ref.watch(adapterNotifierProvider.notifier).activeAdapter;
});

final adapterStateProvider = StreamProvider<AdapterState>((ref) {
  final adapter = ref.watch(activeAdapterProvider);
  return adapter.state;
});
