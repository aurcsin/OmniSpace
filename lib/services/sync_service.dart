// File: lib/services/sync_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/omni_note.dart';
import '../models/sync_metadata.dart';
import 'omni_note_service.dart';

/// Service to sync local DB with remote backend.
///
/// Supports:
///  • Pushing new/updated notes
///  • Pulling down changes since last sync
///  • Deleting notes on both client and server
class SyncService {
  // Singleton instance
  static final SyncService instance = SyncService._internal();
  SyncService._internal();

  // Base URL for sync endpoints
  static const String _baseUrl = 'https://api.yourapp.com/sync';

  /// Performs a full sync cycle: pushes all local notes, then pulls any updates.
  Future<void> syncAll() async {
    await _pushAllNotes();
    await _pullUpdates();
  }

  /// Pushes every local note to the server.
  Future<void> _pushAllNotes() async {
    final notes = OmniNoteService.instance.notes;
    for (final note in notes) {
      await pushNote(note);
    }
  }

  /// Pushes a single [note] (including its attachments) to the server.
  Future<void> pushNote(OmniNote note) async {
    final url = Uri.parse('$_baseUrl/notes');
    final body = _noteToJson(note);

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw SyncException('Failed to push note ${note.id}: ${response.body}');
    }
  }

  /// Pulls down all notes updated since the last sync timestamp.
  Future<void> _pullUpdates() async {
    final metadata = await SyncMetadata.load();
    final since = metadata.lastSyncedAt?.toIso8601String() ?? '';
    final url = Uri.parse('$_baseUrl/updates?since=$since');

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;

      // Deserialize and save each returned note
      final notesJson = data['notes'] as List<dynamic>;
      for (final noteJson in notesJson) {
        final note = OmniNote.fromJson(noteJson as Map<String, dynamic>);
        await OmniNoteService.instance.saveNote(note);
      }

      // Update and persist the new sync timestamp
      metadata.lastSyncedAt = DateTime.parse(data['syncedAt'] as String);
      await metadata.save();
    } else {
      throw SyncException('Failed to pull updates: ${response.body}');
    }
  }

  /// Deletes the note with [id] on both the server and locally.
  Future<void> deleteNote(String id) async {
    final url = Uri.parse('$_baseUrl/notes/$id');
    final response = await http.delete(url);

    if (response.statusCode == 204) {
      await OmniNoteService.instance.deleteNoteById(id);
    } else {
      throw SyncException('Failed to delete note $id: ${response.body}');
    }
  }

  /// Converts an [OmniNote] (and its attachments) into a JSON‐compatible map.
  Map<String, dynamic> _noteToJson(OmniNote note) {
    return {
      'id': note.id,
      'title': note.title,
      'subtitle': note.subtitle,
      'content': note.content,
      'tags': note.tags,
      'createdAt': note.createdAt.toIso8601String(),
      'lastUpdated': note.lastUpdated.toIso8601String(),
      'isPinned': note.isPinned,
      'attachments': note.attachments
          .map((a) => a.toJson())
          .toList(),
    };
  }
}

/// Exception thrown when any sync operation fails.
class SyncException implements Exception {
  final String message;
  SyncException(this.message);

  @override
  String toString() => 'SyncException: $message';
}
