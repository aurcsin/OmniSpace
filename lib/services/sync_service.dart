// File: lib/services/omni_note_service.dart

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../models/omni_note.dart';

/// A ChangeNotifier-backed Hive service for managing OmniNote objects.
class OmniNoteService extends ChangeNotifier {
  OmniNoteService._internal();
  static final OmniNoteService instance = OmniNoteService._internal();

  static const String _boxName = 'omni_notes';
  late final Box<OmniNote> _box;

  /// Initialize the service. Must be called once at app startup,
  /// after all Hive adapters have been registered.
  Future<void> init() async {
    _box = await Hive.openBox<OmniNote>(_boxName);
    notifyListeners();
  }

  /// All notes, including trashed.
  List<OmniNote> get all => _box.values.toList();

  /// Only non-trashed notes.
  List<OmniNote> get notes =>
    _box.values.where((n) => !n.isTrashed).toList();

  /// Only trashed notes.
  List<OmniNote> get trashedNotes =>
    _box.values.where((n) => n.isTrashed).toList();

  /// Lookup by ID.
  OmniNote? getById(String id) => _box.get(id);

  /// Create or update a note.
  Future<void> saveNote(OmniNote note) async {
    await _box.put(note.id, note);
    notifyListeners();
  }

  /// Soft-trash a note.
  Future<void> trashNote(String id) async {
    final note = _box.get(id);
    if (note != null && !note.isTrashed) {
      note.isTrashed = true;
      await _box.put(id, note);
      notifyListeners();
    }
  }

  /// Restore a trashed note.
  Future<void> restoreNote(String id) async {
    final note = _box.get(id);
    if (note != null && note.isTrashed) {
      note.isTrashed = false;
      await _box.put(id, note);
      notifyListeners();
    }
  }

  /// Permanently delete a single note.
  Future<void> deleteNote(String id) async {
    await _box.delete(id);
    notifyListeners();
  }

  /// Permanently delete multiple notes at once.
  Future<void> deletePermanent(List<String> ids) async {
    for (final id in ids) {
      await _box.delete(id);
    }
    notifyListeners();
  }
}
