// lib/services/omni_note_service.dart

import 'package:omnispace/models/omni_note.dart';

class OmniNoteService {
  OmniNoteService._();
  static final instance = OmniNoteService._();

  final List<OmniNote> _notes = [];

  /// All notes.
  List<OmniNote> get notes => List.unmodifiable(_notes);

  /// Only notes marked as trashed.
  List<OmniNote> get trashedNotes =>
      _notes.where((n) => n.isTrashed).toList();

  /// Lookup a note by its ID, or null if not found.
  OmniNote? getById(String id) {
    try {
      return _notes.firstWhere((n) => n.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Save or update a note.
  Future<void> save(OmniNote note) async {
    final idx = _notes.indexWhere((n) => n.id == note.id);
    if (idx >= 0) {
      _notes[idx] = note;
    } else {
      _notes.add(note);
    }
    // TODO: persist _notes to disk or database
  }

  /// Alias for save(), used by UI code expecting saveNote().
  Future<void> saveNote(OmniNote note) => save(note);

  /// Mark a note trashed or un-trashed.
  Future<void> setTrashed(String id, bool isTrashed) async {
    final note = getById(id);
    if (note != null) {
      note.isTrashed = isTrashed;
      await save(note);
    }
  }

  /// Permanently delete notes by their IDs.
  Future<void> deletePermanent(List<String> ids) async {
    _notes.removeWhere((n) => ids.contains(n.id));
    // TODO: persist deletion to disk or database
  }

  /// Permanently delete a single note.
  Future<void> deleteNote(String id) async {
    await deletePermanent([id]);
  }
}
