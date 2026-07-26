import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../domain/entities/adapter_state.dart';
import '../../domain/entities/device.dart';
import '../../domain/entities/remote_key.dart';
import '../storage/token_repository.dart';
import 'base_adapter.dart';
import 'command_mapper.dart';
import 'connection_retry_policy.dart';

class LgAdapter extends BaseAdapter {
  final CommandMapper mapper;
  final TokenRepository tokenRepository;
  final ConnectionRetryPolicy retryPolicy;

  WebSocketChannel? _channel;
  StreamSubscription? _wsSubscription;
  Device? _activeDevice;
  String? _savedClientKey;
  int _requestId = 1;

  LgAdapter({
    CommandMapper? mapper,
    TokenRepository? tokenRepository,
    ConnectionRetryPolicy? retryPolicy,
  })  : mapper = mapper ?? LgCommandMapper(),
        tokenRepository = tokenRepository ?? SecureTokenRepositoryImpl(),
        retryPolicy = retryPolicy ?? const ConnectionRetryPolicy();

  static const List<String> defaultPermissions = [
    "LAUNCH",
    "LAUNCH_WEBAPP",
    "APP_TO_APP",
    "CLOSE",
    "CONTROL_POWER",
    "READ_RUNNING_APPS",
    "READ_TV_CHANNEL_LIST",
    "READ_CURRENT_CHANNEL",
    "READ_INPUT_DEVICE_LIST",
    "WRITE_NOTIFICATION_TOAST",
    "READ_POWER_STATE",
    "CONTROL_INPUT_TEXT",
    "CONTROL_MOUSE_AND_KEYBOARD",
    "READ_INSTALLED_APPS"
  ];

  static Map<String, dynamic> buildRegisterPayload({
    String? clientKey,
    List<String>? permissions,
  }) {
    return {
      "type": "register",
      "id": "register_0",
      "payload": {
        "forcePairing": false,
        "pairingType": "PROMPT",
        if (clientKey != null && clientKey.isNotEmpty) "client-key": clientKey,
        "manifest": {
          "permissions": permissions ?? defaultPermissions,
        }
      }
    };
  }

  @override
  Future<void> connect(Device device) async {
    emitState(const AdapterState.connecting());
    _activeDevice = device;
    _savedClientKey = await tokenRepository.getToken(device.id);

    final portsToTry = device.port == 3001 ? [3001, 3000] : [device.port, 3001, 3000];

    for (final port in portsToTry) {
      try {
        final scheme = port == 3001 ? 'wss' : 'ws';
        final url = '$scheme://${device.ipAddress}:$port';

        final customClient = HttpClient()
          ..badCertificateCallback = (X509Certificate cert, String host, int p) => true;

        final webSocket = await WebSocket.connect(
          url,
          customClient: customClient,
        ).timeout(const Duration(seconds: 4));

        _channel = IOWebSocketChannel(webSocket);
        _activeDevice = device.copyWith(port: port);

        _wsSubscription?.cancel();
        _wsSubscription = _channel?.stream.listen(
          _onMessage,
          onError: (err) {
            emitState(AdapterState.error('LG webOS WebSocket error: $err', device: _activeDevice));
          },
          onDone: () {
            emitState(const AdapterState.disconnected());
          },
        );

        final regPayload = buildRegisterPayload(clientKey: _savedClientKey);
        _channel?.sink.add(jsonEncode(regPayload));

        if (_savedClientKey != null && _savedClientKey!.isNotEmpty) {
          emitState(AdapterState.paired(_activeDevice!));
        } else {
          emitState(AdapterState.pairing(_activeDevice!));
        }
        return; // Connection succeeded
      } catch (_) {
        // Try next fallback port
      }
    }

    emitState(AdapterState.error('Failed to connect to LG TV on ${device.ipAddress} (ports 3001/3000)', device: device));
  }

  void _onMessage(dynamic rawData) {
    if (rawData == null || _activeDevice == null) return;
    try {
      final jsonMap = jsonDecode(rawData.toString());
      final type = jsonMap['type'];
      final payload = jsonMap['payload'];

      if (type == 'registered' && payload != null) {
        final clientKey = payload['client-key']?.toString();
        if (clientKey != null && clientKey.isNotEmpty) {
          _savedClientKey = clientKey;
          tokenRepository.saveToken(_activeDevice!.id, clientKey);
        }
        emitState(AdapterState.paired(_activeDevice!));
      }
    } catch (_) {}
  }

  @override
  Future<void> disconnect() async {
    await _wsSubscription?.cancel();
    await _channel?.sink.close();
    _channel = null;
    _activeDevice = null;
    emitState(const AdapterState.disconnected());
  }

  @override
  Future<void> sendKey(RemoteKey key) async {
    if (_channel == null || _activeDevice == null) return;

    final String uri;
    Map<String, dynamic>? payload;

    switch (key) {
      case RemoteKey.power:
        uri = "ssap://system/turnOff";
        break;
      case RemoteKey.home:
        uri = "ssap://system.launcher/open";
        payload = {"id": "com.webos.app.home"};
        break;
      case RemoteKey.back:
        uri = "ssap://system.navigation/back";
        break;
      case RemoteKey.volumeUp:
        uri = "ssap://tv/volumeUp";
        break;
      case RemoteKey.volumeDown:
        uri = "ssap://tv/volumeDown";
        break;
      case RemoteKey.mute:
        uri = "ssap://tv/setMute";
        payload = {"mute": true};
        break;
      case RemoteKey.playPause:
        uri = "ssap://media.controls/play";
        break;
      case RemoteKey.dpadUp:
        uri = "ssap://tv/up";
        break;
      case RemoteKey.dpadDown:
        uri = "ssap://tv/down";
        break;
      case RemoteKey.dpadLeft:
        uri = "ssap://tv/left";
        break;
      case RemoteKey.dpadRight:
        uri = "ssap://tv/right";
        break;
      case RemoteKey.select:
        uri = "ssap://tv/ok";
        break;
      default:
        uri = "ssap://tv/button";
        payload = {"name": mapper.mapKey(key).value};
        break;
    }

    _sendSsapRequest(uri, payload: payload);
  }

  void _sendSsapRequest(String uri, {Map<String, dynamic>? payload}) {
    final id = 'request_${_requestId++}';
    final requestFrame = <String, dynamic>{
      "type": "request",
      "id": id,
      "uri": uri,
    };
    if (payload != null) {
      requestFrame["payload"] = payload;
    }

    _channel?.sink.add(jsonEncode(requestFrame));
  }

  @override
  Future<void> sendText(String text) async {
    if (_channel == null || _activeDevice == null) return;
    _sendSsapRequest(
      "ssap://com.webos.service.ime/insertText",
      payload: {"text": text},
    );
  }

  @override
  Future<void> launchApp(String appId) async {
    if (_channel == null || _activeDevice == null) return;
    _sendSsapRequest(
      "ssap://system.launcher/launch",
      payload: {"id": appId},
    );
  }
}
