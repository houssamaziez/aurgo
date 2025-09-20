import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  final FlutterSecureStorage _storage;
  static const String _keyAccess = 'ACCESS_TOKEN';

  TokenStorage({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  Future<void> saveToken(String token) async =>
      await _storage.write(key: _keyAccess, value: token);
  Future<String?> readToken() async => await _storage.read(key: _keyAccess);
  Future<void> deleteToken() async => await _storage.delete(key: _keyAccess);
}
