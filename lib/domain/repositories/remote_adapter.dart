import '../entities/adapter_state.dart';
import '../entities/device.dart';
import '../entities/remote_key.dart';

abstract class RemoteAdapter {
  Future<void> connect(Device device);
  Future<void> disconnect();
  Future<void> sendKey(RemoteKey key);
  Future<void> sendText(String text);
  Future<void> launchApp(String appId);

  Stream<AdapterState> get state;
  AdapterState get currentState;
}
