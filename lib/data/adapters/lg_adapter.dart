import 'dart:async';
import '../../domain/entities/adapter_state.dart';
import '../../domain/entities/device.dart';
import '../../domain/entities/remote_key.dart';
import 'base_adapter.dart';
import 'command_mapper.dart';

class LgAdapter extends BaseAdapter {
  final CommandMapper mapper;
  Device? _activeDevice;

  LgAdapter({CommandMapper? mapper}) : mapper = mapper ?? LgCommandMapper();

  @override
  Future<void> connect(Device device) async {
    emitState(const AdapterState.connecting());
    _activeDevice = device;
    await Future.delayed(const Duration(milliseconds: 300));
    emitState(AdapterState.paired(device));
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
}
