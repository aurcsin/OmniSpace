// File: lib/services/cloud_sync_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

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

  /// Pushes a note to the cloud.
  ///
  /// If no auth token is stored, an [Exception] is thrown. The note is
  /// serialized to JSON and sent via a POST request to `$_baseUrl/notes`.
  Future<void> pushNote(OmniNote note) async {
    final token = await _token;
    if (token == null) {
      throw Exception('No auth token found');
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/notes'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(note.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to push note: ${response.body}');
    }
  }
}
