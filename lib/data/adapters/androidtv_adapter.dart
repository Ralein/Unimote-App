import 'dart:async';
import 'dart:io';
import '../../domain/entities/adapter_state.dart';
import '../../domain/entities/device.dart';
import '../../domain/entities/remote_key.dart';
import 'base_adapter.dart';
import 'command_mapper.dart';

class AndroidTvAdapter extends BaseAdapter {
  final CommandMapper mapper;
  Device? _activeDevice;
  int _activePort = 6467;

  AndroidTvAdapter({CommandMapper? mapper})
      : mapper = mapper ?? FireTvCommandMapper();

  @override
  Future<void> connect(Device device) async {
    emitState(const AdapterState.connecting());
    _activeDevice = device;

    final targetPorts = [device.port, 6467, 5555];

    for (final port in targetPorts) {
      try {
        final socket = await Socket.connect(
          device.ipAddress,
          port,
          timeout: const Duration(seconds: 2),
        );
        socket.destroy();
        _activePort = port;
        final connectedDevice = device.copyWith(port: port);
        emitState(AdapterState.paired(connectedDevice));
        return;
      } catch (_) {}
    }

    emitState(
      AdapterState.error(
        'Failed to connect to Eyeplus / Google TV on ${device.ipAddress} (tested ports 6467 & 5555). Ensure Network Debugging is enabled in TV Settings -> System -> Developer Options or switch to Bluetooth mode.',
        device: device,
      ),
    );
  }

  @override
  Future<void> disconnect() async {
    _activeDevice = null;
    emitState(const AdapterState.disconnected());
  }

  @override
  Future<void> sendKey(RemoteKey key) async {
    if (_activeDevice == null) return;
    mapper.mapKey(key);
  }

  @override
  Future<void> sendText(String text) async {}

  @override
  Future<void> launchApp(String appId) async {}

  int get activePort => _activePort;
}
