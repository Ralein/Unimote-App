import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class TokenRepository {
  Future<void> saveToken(String deviceId, String token);
  Future<String?> getToken(String deviceId);
  Future<void> deleteToken(String deviceId);
}

class SecureTokenRepositoryImpl implements TokenRepository {
  final FlutterSecureStorage _storage;

  SecureTokenRepositoryImpl({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  @override
  Future<void> saveToken(String deviceId, String token) async {
    await _storage.write(key: 'token_$deviceId', value: token);
  }

  @override
  Future<String?> getToken(String deviceId) async {
    return await _storage.read(key: 'token_$deviceId');
  }

  @override
  Future<void> deleteToken(String deviceId) async {
    await _storage.delete(key: 'token_$deviceId');
  }
}
