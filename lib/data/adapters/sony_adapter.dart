import 'dart:async';
import 'package:dio/dio.dart';
import '../../domain/entities/adapter_state.dart';
import '../../domain/entities/device.dart';
import '../../domain/entities/remote_key.dart';
import 'base_adapter.dart';
import 'command_mapper.dart';

class SonyAdapter extends BaseAdapter {
  final Dio _dio;
  final CommandMapper mapper;
  Device? _activeDevice;
  final String _preSharedKey;

  SonyAdapter({
    Dio? dio,
    CommandMapper? mapper,
    String? preSharedKey,
  })  : _dio = dio ?? Dio(),
        mapper = mapper ?? MockCommandMapper(),
        _preSharedKey = preSharedKey ?? '0000';

  @override
  Future<void> connect(Device device) async {
    emitState(const AdapterState.connecting());
    _activeDevice = device;
    await Future.delayed(const Duration(milliseconds: 200));
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

    final irccCode = _getSonyIrccCode(key);
    final soapBody = '''<?xml version="1.0"?>
<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
  <s:Body>
    <u:X_SendIRCC xmlns:u="urn:schemas-sony-com:service:IRCC:1">
      <IRCCCode>$irccCode</IRCCCode>
    </u:X_SendIRCC>
  </s:Body>
</s:Envelope>''';

    try {
      await _dio.post(
        'http://${_activeDevice!.ipAddress}/sony/IRCC',
        options: Options(
          headers: {
            'X-Auth-PSK': _preSharedKey,
            'SOAPACTION': '"urn:schemas-sony-com:service:IRCC:1#X_SendIRCC"',
            'Content-Type': 'text/xml; charset=UTF-8',
          },
        ),
        data: soapBody,
      );
    } catch (_) {}
  }

  String _getSonyIrccCode(RemoteKey key) {
    switch (key) {
      case RemoteKey.power:
        return 'AAAAAQAAAAEAAAAVAw==';
      case RemoteKey.home:
        return 'AAAAAQAAAAEAAABgAw==';
      case RemoteKey.back:
        return 'AAAAAgAAAJcAAAAjAw==';
      case RemoteKey.dpadUp:
        return 'AAAAAQAAAAEAAAB0Aw==';
      case RemoteKey.dpadDown:
        return 'AAAAAQAAAAEAAAB1Aw==';
      case RemoteKey.dpadLeft:
        return 'AAAAAQAAAAEAAAA0Aw==';
      case RemoteKey.dpadRight:
        return 'AAAAAQAAAAEAAAAzAw==';
      case RemoteKey.select:
        return 'AAAAAQAAAAEAAABlAw==';
      case RemoteKey.volumeUp:
        return 'AAAAAQAAAAEAAAASAw==';
      case RemoteKey.volumeDown:
        return 'AAAAAQAAAAEAAAATAw==';
      case RemoteKey.mute:
        return 'AAAAAQAAAAEAAAAUAw==';
      default:
        return 'AAAAAQAAAAEAAABgAw==';
    }
  }

  @override
  Future<void> sendText(String text) async {}

  @override
  Future<void> launchApp(String appId) async {}
}
