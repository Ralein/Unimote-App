import 'device.dart';

enum AdapterStateStatus {
  disconnected,
  connecting,
  paired,
  error,
}

class AdapterState {
  final AdapterStateStatus status;
  final Device? connectedDevice;
  final String? errorMessage;

  const AdapterState({
    required this.status,
    this.connectedDevice,
    this.errorMessage,
  });

  const AdapterState.disconnected()
      : status = AdapterStateStatus.disconnected,
        connectedDevice = null,
        errorMessage = null;

  const AdapterState.connecting()
      : status = AdapterStateStatus.connecting,
        connectedDevice = null,
        errorMessage = null;

  const AdapterState.paired(Device device)
      : status = AdapterStateStatus.paired,
        connectedDevice = device,
        errorMessage = null;

  const AdapterState.error(String message)
      : status = AdapterStateStatus.error,
        connectedDevice = null,
        errorMessage = message;

  bool get isConnected => status == AdapterStateStatus.paired;
  bool get isConnecting => status == AdapterStateStatus.connecting;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdapterState &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          connectedDevice == other.connectedDevice &&
          errorMessage == other.errorMessage;

  @override
  int get hashCode =>
      status.hashCode ^ connectedDevice.hashCode ^ errorMessage.hashCode;
}
