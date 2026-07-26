import 'dart:async';
import 'package:flutter/services.dart';
import '../../domain/entities/adapter_state.dart';
import '../../domain/entities/device.dart';
import '../../domain/entities/remote_key.dart';
import 'base_adapter.dart';
import 'ir_code_database.dart';

class IrAdapter extends BaseAdapter {
  static const MethodChannel _channel = MethodChannel('unimote/ir');
  Device? _activeDevice;

  Future<bool> hasIrEmitter() async {
    try {
      final bool? result = await _channel.invokeMethod<bool>('hasIrEmitter');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> connect(Device device) async {
    emitState(const AdapterState.connecting());
    _activeDevice = device;

    final hasEmitter = await hasIrEmitter();
    if (!hasEmitter) {
      emitState(
        AdapterState.error(
          'No IR Blaster hardware detected on this phone. Use Wi-Fi TV adapters instead.',
          device: device,
        ),
      );
      return;
    }

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
    final signal = IrCodeDatabase.getSignal(key);

    try {
      await _channel.invokeMethod('transmit', {
        'frequency': signal.frequency,
        'pattern': signal.pattern,
      });
    } catch (e) {
      emitState(AdapterState.error('IR Transmission failed: $e', device: _activeDevice));
    }
  }

  @override
  Future<void> sendText(String text) async {}

  @override
  Future<void> launchApp(String appId) async {}
}
