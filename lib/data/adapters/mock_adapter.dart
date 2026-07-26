import 'dart:async';
import '../../domain/entities/adapter_state.dart';
import '../../domain/entities/device.dart';
import '../../domain/entities/remote_key.dart';
import '../../domain/repositories/remote_adapter.dart';

class MockAdapter implements RemoteAdapter {
  final StreamController<AdapterState> _stateController =
      StreamController<AdapterState>.broadcast();
  AdapterState _currentState = const AdapterState.disconnected();

  final List<RemoteKey> keyLogs = [];
  final List<String> textLogs = [];
  final List<String> appLogs = [];

  MockAdapter() {
    _stateController.add(_currentState);
  }

  @override
  AdapterState get currentState => _currentState;

  @override
  Stream<AdapterState> get state => _stateController.stream;

  void _setState(AdapterState newState) {
    _currentState = newState;
    _stateController.add(newState);
  }

  @override
  Future<void> connect(Device device) async {
    _setState(const AdapterState.connecting());
    await Future.delayed(const Duration(milliseconds: 300));
    _setState(AdapterState.paired(device));
  }

  @override
  Future<void> disconnect() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _setState(const AdapterState.disconnected());
  }

  @override
  Future<void> sendKey(RemoteKey key) async {
    keyLogs.add(key);
  }

  @override
  Future<void> sendText(String text) async {
    textLogs.add(text);
  }

  @override
  Future<void> launchApp(String appId) async {
    appLogs.add(appId);
  }

  void dispose() {
    _stateController.close();
  }
}
