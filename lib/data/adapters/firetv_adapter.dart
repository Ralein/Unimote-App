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

  FireTvAdapter({CommandMapper? mapper})
      : mapper = mapper ?? FireTvCommandMapper();

  @override
  Future<void> connect(Device device) async {
    emitState(const AdapterState.connecting());
    _activeDevice = device;

    if (Platform.isIOS) {
      emitState(
        AdapterState.error(
          'Fire TV control requires ADB network debugging. iOS system security policies restrict native ADB network shells. Switch to an Android device or use Wi-Fi TV adapters.',
          device: device,
        ),
      );
      return;
    }

    try {
      final socket = await Socket.connect(
        device.ipAddress,
        device.port,
        timeout: const Duration(seconds: 4),
      );
      socket.destroy();
      emitState(AdapterState.paired(device));
    } catch (e) {
      emitState(
        AdapterState.error(
          'Failed to connect to Fire TV ADB on ${device.ipAddress}:${device.port}. Ensure ADB Debugging is enabled in TV Settings -> My Fire TV -> Developer Options.',
          device: device,
        ),
      );
    }
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
}
