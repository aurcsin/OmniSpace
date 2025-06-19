// File: lib/services/cloud_sync_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/omni_note.dart';
import 'secure_storage_service.dart';
import 'auth_service.dart';

/// Exception thrown when cloud sync operations fail.
class CloudSyncException implements Exception {
  final String message;
  CloudSyncException(this.message);
  @override
  String toString() => 'CloudSyncException: $message';
}

/// A service for synchronizing notes with a remote server.
class CloudSyncService {
  CloudSyncService._internal([http.Client? client]) : _client = client ?? http.Client();
  static final CloudSyncService instance = CloudSyncService._internal();

  final http.Client _client;
  static const String _baseUrl = 'https://api.example.com';

  /// Retrieves the stored auth token.
  Future<String> _getToken() async {
    final token = await SecureStorageService.instance.read('auth_token');
    if (token == null) {
      throw CloudSyncException('No auth token found. Please log in.');
    }
    return token;
  }

  /// Pushes (creates or updates) a note to the cloud.
  Future<void> pushNote(OmniNote note) async {
    final token = await _getToken();
    final url = Uri.parse('$_baseUrl/notes/${note.id}');
    final response = await _client.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(note.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw CloudSyncException('Failed to push note: ${response.statusCode} ${response.body}');
    }
  }

  /// Fetches all notes for the current user from the cloud.
  Future<List<OmniNote>> fetchNotes() async {
    final token = await _getToken();
    final url = Uri.parse('$_baseUrl/notes');
    final response = await _client.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> list = jsonDecode(response.body);
      return list.map((json) => OmniNote.fromJson(json)).toList();
    } else {
      throw CloudSyncException('Failed to fetch notes: ${response.statusCode} ${response.body}');
    }
  }

  /// Deletes a note from the cloud.
  Future<void> deleteNote(String id) async {
    final token = await _getToken();
    final url = Uri.parse('$_baseUrl/notes/$id');
    final response = await _client.delete(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 204) {
      throw CloudSyncException('Failed to delete note: ${response.statusCode} ${response.body}');
    }
  }
}
