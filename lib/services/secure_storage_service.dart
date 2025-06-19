// File: lib/services/secure_storage_service.dart

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Simple wrapper around [FlutterSecureStorage] for storing sensitive data.
/// Adds platform-specific options and bulk operations.
class SecureStorageService {
  SecureStorageService._internal();
  static final SecureStorageService instance = SecureStorageService._internal();

  // Configure Android encrypted shared preferences
  static final AndroidOptions _androidOptions = AndroidOptions(
    encryptedSharedPreferences: true,
  );

  // Configure iOS Keychain accessibility (first unlock after device start)
  static final IOSOptions _iOSOptions = IOSOptions(
    accessibility: KeychainAccessibility.first_unlock,
  );

  // FlutterSecureStorage instance with platform-specific options
  final FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: _androidOptions,
    iOptions: _iOSOptions,
  );

  /// Write a value for [key].
  Future<void> write(String key, String value) {
    return _storage.write(key: key, value: value);
  }

  /// Read the value for [key], or null if not present.
  Future<String?> read(String key) {
    return _storage.read(key: key);
  }

  /// Deletes the entry for [key].
  Future<void> delete(String key) {
    return _storage.delete(key: key);
  }

  /// Deletes all entries.
  Future<void> deleteAll() {
    return _storage.deleteAll();
  }

  /// Reads all key-value pairs.
  Future<Map<String, String>> readAll() {
    return _storage.readAll();
  }

  /// Checks if [key] exists.
  Future<bool> containsKey(String key) {
    return _storage.containsKey(key: key);
  }
}
