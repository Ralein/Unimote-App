import 'dart:async';
import 'package:dio/dio.dart';
import '../../domain/entities/adapter_state.dart';
import '../../domain/entities/device.dart';
import '../../domain/entities/remote_key.dart';
import '../storage/token_repository.dart';
import 'base_adapter.dart';
import 'command_mapper.dart';

class VizioAdapter extends BaseAdapter {
  final Dio _dio;
  final CommandMapper mapper;
  final TokenRepository tokenRepository;

  Device? _activeDevice;
  String? _authToken;

  VizioAdapter({
    Dio? dio,
    CommandMapper? mapper,
    TokenRepository? tokenRepository,
  })  : _dio = dio ?? Dio(),
        mapper = mapper ?? MockCommandMapper(),
        tokenRepository = tokenRepository ?? SecureTokenRepositoryImpl();

  @override
  Future<void> connect(Device device) async {
    emitState(const AdapterState.connecting());
    _activeDevice = device;
    _authToken = await tokenRepository.getToken(device.id);

    try {
      if (_authToken != null && _authToken!.isNotEmpty) {
        emitState(AdapterState.paired(device));
      } else {
        emitState(AdapterState.pairing(device));
      }
    } catch (e) {
      emitState(AdapterState.error('Vizio connection error: $e', device: device));
    }
  }

  Future<void> startPairing() async {
    if (_activeDevice == null) return;
    try {
      await _dio.put(
        'https://${_activeDevice!.ipAddress}:${_activeDevice!.port}/pairing/start',
        data: {
          "DEVICE_ID": "unimote_mobile",
          "DEVICE_NAME": "Unimote Remote"
        },
      );
    } catch (_) {}
  }

  Future<void> completePairingWithPin(String pin) async {
    if (_activeDevice == null) return;
    try {
      final response = await _dio.put(
        'https://${_activeDevice!.ipAddress}:${_activeDevice!.port}/pairing/pair',
        data: {
          "DEVICE_ID": "unimote_mobile",
          "RESPONSE_PAIRING_TOKEN": pin,
        },
      );

      final token = response.data['ITEM']?['AUTH_TOKEN']?.toString();
      if (token != null) {
        _authToken = token;
        await tokenRepository.saveToken(_activeDevice!.id, token);
        emitState(AdapterState.paired(_activeDevice!));
      }
    } catch (e) {
      emitState(AdapterState.error('Failed to pair Vizio TV with PIN: $e', device: _activeDevice));
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
    try {
      await _dio.put(
        'https://${_activeDevice!.ipAddress}:${_activeDevice!.port}/key_command/',
        options: Options(
          headers: {
            if (_authToken != null) "AUTH_TOKEN": _authToken,
          },
        ),
        data: {
          "KEY_LIST": [
            {
              "CODESET": 0,
              "CODE": mapper.mapKey(key).value,
              "ACTION": "KEY_PRESS"
            }
          ]
        },
      );
    } catch (_) {}
  }

  @override
  Future<void> sendText(String text) async {}

  @override
  Future<void> launchApp(String appId) async {}
}
