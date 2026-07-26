import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/adapters/mock_adapter.dart';
import '../../domain/entities/adapter_state.dart';
import '../../domain/entities/device.dart';
import '../../domain/repositories/remote_adapter.dart';

final mockDevice = const Device(
  id: 'mock-tv-01',
  name: 'Living Room TV (Mock)',
  brand: DeviceBrand.mock,
  ipAddress: '192.168.1.100',
  port: 8080,
);

final mockAdapterProvider = Provider<MockAdapter>((ref) {
  final adapter = MockAdapter();
  adapter.connect(mockDevice);
  ref.onDispose(() => adapter.dispose());
  return adapter;
});

final activeAdapterProvider = Provider<RemoteAdapter>((ref) {
  return ref.watch(mockAdapterProvider);
});

final adapterStateProvider = StreamProvider<AdapterState>((ref) {
  final adapter = ref.watch(activeAdapterProvider);
  return adapter.state;
});
