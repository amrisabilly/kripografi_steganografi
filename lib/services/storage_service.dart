import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  final _storage = const FlutterSecureStorage();

  final String _tokenKey = 'auth_token';
  final String _privateKey = 'private_key';

  // --- Token ---
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  // --- Private Key (SANGAT PENTING) ---
  Future<void> savePrivateKey(String key) async {
    await _storage.write(key: _privateKey, value: key);
  }

  Future<String?> getPrivateKey() async {
    return await _storage.read(key: _privateKey);
  }

  // --- Hapus Saat Logout ---
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}