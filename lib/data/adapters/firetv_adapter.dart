import 'dart:async';
import 'dart:io';
import '../../domain/entities/adapter_state.dart';
import '../../domain/entities/device.dart';
import '../../domain/entities/remote_key.dart';
import 'base_adapter.dart';
import 'command_mapper.dart';

class FireTvAdapter extends BaseAdapter {
  final CommandMapper mapper;
  Device? _activeDevice;
  int _activePort = 5555;

  FireTvAdapter({CommandMapper? mapper})
      : mapper = mapper ?? FireTvCommandMapper();

  @override
  Future<void> connect(Device device) async {
    emitState(const AdapterState.connecting());
    _activeDevice = device;

    if (Platform.isIOS) {
      emitState(
        AdapterState.error(
          'Fire TV control requires ADB/TLS network debugging. iOS system security policies restrict native ADB sockets. Switch to an Android device or use Wi-Fi TV adapters.',
          device: device,
        ),
      );
      return;
    }

    final targetPorts = [device.port, 5555, 6467];

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
        'Failed to connect to Fire TV / Android TV on ${device.ipAddress} (tested ports 5555 & 6467). Ensure ADB Debugging is enabled in TV Settings -> My Fire TV / Device Preferences -> Developer Options.',
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
    if (_activeDevice == null || Platform.isIOS) return;
    mapper.mapKey(key);
  }

  @override
  Future<void> sendText(String text) async {}

  @override
  Future<void> launchApp(String appId) async {}

  int get activePort => _activePort;
}
