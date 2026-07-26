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

class SamsungAdapter extends BaseAdapter {
  final CommandMapper mapper;
  final TokenRepository tokenRepository;
  final ConnectionRetryPolicy retryPolicy;

  WebSocketChannel? _channel;
  StreamSubscription? _wsSubscription;
  Device? _activeDevice;
  String? _savedToken;

  SamsungAdapter({
    CommandMapper? mapper,
    TokenRepository? tokenRepository,
    ConnectionRetryPolicy? retryPolicy,
  })  : mapper = mapper ?? SamsungCommandMapper(),
        tokenRepository = tokenRepository ?? SecureTokenRepositoryImpl(),
        retryPolicy = retryPolicy ?? const ConnectionRetryPolicy();

  static String encodeAppName(String appName) {
    return base64Encode(utf8.encode(appName));
  }

  static String buildUrl({
    required String ip,
    required int port,
    required String appName,
    String? token,
  }) {
    final base64Name = encodeAppName(appName);
    final scheme = port == 8002 ? 'wss' : 'ws';
    var url = '$scheme://$ip:$port/api/v2/channels/samsung.remote.control?name=$base64Name';
    if (token != null && token.isNotEmpty) {
      url += '&token=$token';
    }
    return url;
  }

  @override
  Future<void> connect(Device device) async {
    emitState(const AdapterState.connecting());
    _activeDevice = device;
    _savedToken = await tokenRepository.getToken(device.id);

    final portsToTry = device.port == 8002 ? [8002, 8001] : [device.port, 8002, 8001];

    for (final port in portsToTry) {
      try {
        final url = buildUrl(
          ip: device.ipAddress,
          port: port,
          appName: 'Unimote',
          token: _savedToken,
        );

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
            emitState(AdapterState.error('Samsung WebSocket error: $err', device: _activeDevice));
          },
          onDone: () {
            emitState(const AdapterState.disconnected());
          },
        );

        if (_savedToken != null && _savedToken!.isNotEmpty) {
          emitState(AdapterState.paired(_activeDevice!));
        } else {
          emitState(AdapterState.pairing(_activeDevice!));
        }
        return; // Connection succeeded
      } catch (_) {
        // Try next fallback port
      }
    }

    emitState(AdapterState.error('Failed to connect to Samsung TV on ${device.ipAddress} (ports 8002/8001)', device: device));
  }

  void _onMessage(dynamic rawData) {
    if (rawData == null || _activeDevice == null) return;
    try {
      final jsonMap = jsonDecode(rawData.toString());
      final event = jsonMap['event'];
      final data = jsonMap['data'];

      if (event == 'ms.channel.connect') {
        if (data != null && data['token'] != null) {
          final newToken = data['token'].toString();
          _savedToken = newToken;
          tokenRepository.saveToken(_activeDevice!.id, newToken);
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
    final payload = mapper.mapKey(key);

    final jsonFrame = {
      "method": "ms.remote.control",
      "params": {
        "Cmd": "Click",
        "DataOfCmd": payload.value,
        "Option": "false",
        "TypeOfRemote": "SendRemoteKey"
      }
    };

    _channel?.sink.add(jsonEncode(jsonFrame));
  }

  @override
  Future<void> sendText(String text) async {
    if (_channel == null || _activeDevice == null) return;

    final jsonFrame = {
      "method": "ms.remote.control",
      "params": {
        "Cmd": base64Encode(utf8.encode(text)),
        "DataOfCmd": "base64",
        "Option": "false",
        "TypeOfRemote": "SendInputString"
      }
    };

    _channel?.sink.add(jsonEncode(jsonFrame));
  }

  @override
  Future<void> launchApp(String appId) async {
    if (_channel == null || _activeDevice == null) return;

    final jsonFrame = {
      "method": "ms.channel.emit",
      "params": {
        "event": "ed.apps.launch",
        "to": "host",
        "data": {
          "action_type": "DEEP_LINK",
          "appId": appId,
        }
      }
    };

    _channel?.sink.add(jsonEncode(jsonFrame));
  }
}
