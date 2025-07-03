// File: lib/services/sync_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/omni_note.dart';
import '../models/sync_metadata.dart';
import '../services/omni_note_service.dart';
import '../services/secure_storage_service.dart';

/// Exception thrown when any sync operation fails.
class SyncException implements Exception {
  final String message;
  SyncException(this.message);
  @override
  String toString() => 'SyncException: $message';
}

/// A service to synchronize local notes (and attachments) with a remote backend.
class SyncService {
  SyncService._internal();
  static final SyncService instance = SyncService._internal();

  static const String _baseUrl = 'https://api.yourapp.com/sync';

  /// Performs a full sync cycle: pushes all local notes, then pulls any updates.
  Future<void> syncAll() async {
    await _pushAllNotes();
    await _pullUpdates();
  }

  Future<void> _pushAllNotes() async {
    final notes = OmniNoteService.instance.notes;
    for (final note in notes) {
      await pushNote(note);
    }
  }

  Future<void> pushNote(OmniNote note) async {
    final token = await SecureStorageService.instance.read('auth_token');
    if (token == null) {
      throw SyncException('Authentication required');
    }
    final url = Uri.parse('$_baseUrl/notes');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(_noteToJson(note)),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw SyncException(
        'Failed to push note ${note.id}: ${response.statusCode} ${response.body}',
      );
    }
  }

  Future<void> _pullUpdates() async {
    final token = await SecureStorageService.instance.read('auth_token');
    if (token == null) {
      throw SyncException('Authentication required');
    }
    final metadata = await SyncMetadata.load();
    final since = metadata.lastSyncedAt?.toIso8601String() ?? '';
    final url = Uri.parse('$_baseUrl/updates?since=$since');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final notesJson = data['notes'] as List<dynamic>;
      for (final noteJson in notesJson) {
        final note = OmniNote.fromJson(noteJson as Map<String, dynamic>);
        await OmniNoteService.instance.saveNote(note);
      }
      metadata.lastSyncedAt = DateTime.parse(data['syncedAt'] as String);
      await metadata.save();
    } else {
      throw SyncException(
        'Failed to pull updates: ${response.statusCode} ${response.body}',
      );
    }
  }

  Future<void> deleteNote(String id) async {
    final token = await SecureStorageService.instance.read('auth_token');
    if (token == null) {
      throw SyncException('Authentication required');
    }
    final url = Uri.parse('$_baseUrl/notes/$id');
    final response = await http.delete(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 204) {
      await OmniNoteService.instance.deleteNote(id);
    } else {
      throw SyncException(
        'Failed to delete note $id: ${response.statusCode} ${response.body}',
      );
    }
  }

  Map<String, dynamic> _noteToJson(OmniNote note) => {
        'id': note.id,
        'title': note.title,
        'subtitle': note.subtitle,
        'content': note.content,
        'tags': note.tags,
        'createdAt': note.createdAt.toIso8601String(),
        'lastUpdated': note.lastUpdated.toIso8601String(),
        'isPinned': note.isPinned,
        'attachments': note.attachments.map((a) => a.toJson()).toList(),
      };
}
