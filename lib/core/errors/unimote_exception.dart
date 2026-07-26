abstract class UnimoteException implements Exception {
  final String message;
  final String? recoverySuggestion;

  const UnimoteException(this.message, {this.recoverySuggestion});

  @override
  String toString() => '$runtimeType: $message${recoverySuggestion != null ? " ($recoverySuggestion)" : ""}';
}

class NetworkUnreachableException extends UnimoteException {
  const NetworkUnreachableException(
    super.message, {
    super.recoverySuggestion = 'Check your phone Wi-Fi connection and ensure the TV is on the same local subnet.',
  });
}

class AuthExpiredException extends UnimoteException {
  const AuthExpiredException(
    super.message, {
    super.recoverySuggestion = 'Re-pair with the TV to grant fresh permission access.',
  });
}

class DeviceOfflineException extends UnimoteException {
  const DeviceOfflineException(
    super.message, {
    super.recoverySuggestion = 'Turn on the TV manually or use Wake-on-LAN power on.',
  });
}

class HardwareNotSupportedException extends UnimoteException {
  const HardwareNotSupportedException(
    super.message, {
    super.recoverySuggestion = 'This feature requires hardware not available on your device (e.g. Android IR Blaster or ADB network shell).',
  });
}
