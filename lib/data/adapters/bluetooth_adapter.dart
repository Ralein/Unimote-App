import 'dart:async';
import 'package:flutter/services.dart';
import '../../domain/entities/adapter_state.dart';
import '../../domain/entities/device.dart';
import '../../domain/entities/remote_key.dart';
import 'base_adapter.dart';

class BluetoothAdapter extends BaseAdapter {
  static const MethodChannel _channel = MethodChannel('unimote/bluetooth');

  static const Map<RemoteKey, int> keyToHidCodeMap = {
    RemoteKey.power: 0x0030,
    RemoteKey.home: 0x0223,
    RemoteKey.back: 0x0224,
    RemoteKey.select: 0x0041,
    RemoteKey.dpadUp: 0x0042,
    RemoteKey.dpadDown: 0x0043,
    RemoteKey.dpadLeft: 0x0044,
    RemoteKey.dpadRight: 0x0045,
    RemoteKey.volumeUp: 0x00E9,
    RemoteKey.volumeDown: 0x00EA,
    RemoteKey.mute: 0x00E2,
    RemoteKey.playPause: 0x00CD,
    RemoteKey.inputSource: 0x0080,
    RemoteKey.num0: 0x0027,
    RemoteKey.num1: 0x001E,
    RemoteKey.num2: 0x001F,
    RemoteKey.num3: 0x0020,
    RemoteKey.num4: 0x0021,
    RemoteKey.num5: 0x0022,
    RemoteKey.num6: 0x0023,
    RemoteKey.num7: 0x0024,
    RemoteKey.num8: 0x0025,
    RemoteKey.num9: 0x0026,
  };

  @override
  Future<void> connect(Device device) async {
    emitState(const AdapterState.connecting());

    try {
      final bool connected = await _channel.invokeMethod('connectDevice', {
        'macAddress': device.ipAddress,
        'name': device.name,
      });

      if (connected) {
        emitState(AdapterState.paired(device));
      } else {
        emitState(AdapterState.error('Failed to pair via Bluetooth with ${device.name}', device: device));
      }
    } on PlatformException catch (e) {
      emitState(AdapterState.error('Bluetooth error: ${e.message}', device: device));
    } catch (e) {
      emitState(AdapterState.error('Bluetooth connection failed: $e', device: device));
    }
  }

  @override
  Future<void> disconnect() async {
    try {
      await _channel.invokeMethod('disconnectDevice');
    } catch (_) {}
    emitState(const AdapterState.disconnected());
  }

  @override
  Future<void> sendKey(RemoteKey key) async {
    final hidCode = keyToHidCodeMap[key];
    if (hidCode == null) return;

    try {
      await _channel.invokeMethod('sendHidKeycode', {
        'hidCode': hidCode,
        'keyName': key.name,
      });
    } catch (_) {}
  }

  @override
  Future<void> sendText(String text) async {
    try {
      await _channel.invokeMethod('sendTextInput', {'text': text});
    } catch (_) {}
  }

  @override
  Future<void> launchApp(String appId) async {
    await sendKey(RemoteKey.home);
  }

  static Future<bool> isBluetoothAvailable() async {
    try {
      final bool available = await _channel.invokeMethod('isBluetoothAvailable');
      return available;
    } catch (_) {
      return false;
    }
  }
}
