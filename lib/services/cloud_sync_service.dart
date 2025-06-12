// File: lib/services/cloud_sync_service.dart

import '../models/omni_note.dart';
import 'secure_storage_service.dart';

/// Lightweight cloud sync stub that authenticates using a stored token.
class CloudSyncService {
  CloudSyncService._internal();
  static final CloudSyncService instance = CloudSyncService._internal();

  /// Endpoint base URL (placeholder).
  final String _baseUrl = 'https://api.example.com';

  /// Reads auth token from secure storage.
  Future<String?> get _token async =>
      SecureStorageService.instance.read('auth_token');

  /// Pushes a note to the cloud. This method is a stub and does not
  /// perform network requests in this example.
  Future<void> pushNote(OmniNote note) async {
    final token = await _token;
    // TODO: send note to server using token
    await Future.delayed(const Duration(milliseconds: 100));
  }
}
