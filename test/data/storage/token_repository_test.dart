import 'package:flutter_test/flutter_test.dart';
import 'package:unimote/data/storage/token_repository.dart';

class MemoryTokenRepository implements TokenRepository {
  final Map<String, String> _storage = {};

  @override
  Future<void> saveToken(String deviceId, String token) async {
    _storage[deviceId] = token;
  }

  @override
  Future<String?> getToken(String deviceId) async {
    return _storage[deviceId];
  }

  @override
  Future<void> deleteToken(String deviceId) async {
    _storage.remove(deviceId);
  }
}

void main() {
  group('TokenRepository Unit Tests', () {
    late TokenRepository repo;

    setUp(() {
      repo = MemoryTokenRepository();
    });

    test('saveToken, getToken, and deleteToken lifecycle', () async {
      expect(await repo.getToken('tv-101'), isNull);

      await repo.saveToken('tv-101', 'samsung_token_xyz987');
      expect(await repo.getToken('tv-101'), equals('samsung_token_xyz987'));

      await repo.deleteToken('tv-101');
      expect(await repo.getToken('tv-101'), isNull);
    });
  });
}
