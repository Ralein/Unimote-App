import 'dart:async';
import 'package:dio/dio.dart';
import '../../domain/entities/adapter_state.dart';
import '../../domain/entities/device.dart';
import '../../domain/entities/remote_key.dart';
import 'base_adapter.dart';
import 'command_mapper.dart';
import 'connection_retry_policy.dart';

class RokuAdapter extends BaseAdapter {
  final Dio _dio;
  final CommandMapper mapper;
  final ConnectionRetryPolicy retryPolicy;

  Device? _activeDevice;

  RokuAdapter({
    Dio? dio,
    CommandMapper? mapper,
    ConnectionRetryPolicy? retryPolicy,
  })  : _dio = dio ?? Dio(),
        mapper = mapper ?? RokuCommandMapper(),
        retryPolicy = retryPolicy ?? const ConnectionRetryPolicy();

  @override
  Future<void> connect(Device device) async {
    emitState(const AdapterState.connecting());
    _activeDevice = device;

    try {
      await retryPolicy.execute(() async {
        // Quick ECP ping
        final response = await _dio.get(
          'http://${device.ipAddress}:${device.port}/query/device-info',
          options: Options(responseType: ResponseType.plain),
        );
        if (response.statusCode != 200) {
          throw Exception('Failed to connect to Roku ECP on ${device.ipAddress}');
        }
      });
      emitState(AdapterState.paired(device));
    } catch (e) {
      emitState(AdapterState.error('Roku connection failed: ${e.toString()}', device: device));
    }
  }

  @override
  Future<void> disconnect() async {
    _activeDevice = null;
    emitState(const AdapterState.disconnected());
  }

  @override
  Future<void> sendKey(RemoteKey key) async {
    if (_activeDevice == null) return;
    final payload = mapper.mapKey(key);

    try {
      await _dio.post(
        'http://${_activeDevice!.ipAddress}:${_activeDevice!.port}${payload.value}',
      );
    } catch (e) {
      emitState(AdapterState.error('Failed to send key to Roku: $e', device: _activeDevice));
    }
  }

  @override
  Future<void> sendText(String text) async {
    if (_activeDevice == null) return;
    for (final char in text.runes) {
      final strChar = String.fromCharCode(char);
      final encoded = Uri.encodeComponent(strChar);
      try {
        await _dio.post(
          'http://${_activeDevice!.ipAddress}:${_activeDevice!.port}/keypress/Lit_$encoded',
        );
      } catch (_) {}
    }
  }

  @override
  Future<void> launchApp(String appId) async {
    if (_activeDevice == null) return;
    try {
      await _dio.post(
        'http://${_activeDevice!.ipAddress}:${_activeDevice!.port}/launch/$appId',
      );
    } catch (_) {}
  }
}
