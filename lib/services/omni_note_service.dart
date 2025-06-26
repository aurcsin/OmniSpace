// File: lib/services/omni_note_service.dart

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import 'package:omnispace/models/omni_note.dart';
import 'package:omnispace/models/zone_theme.dart';

/// ChangeNotifier-backed Hive box for OmniNote.
class OmniNoteService extends ChangeNotifier {
  OmniNoteService._internal();
  static final OmniNoteService instance = OmniNoteService._internal();

  static const String _boxName = 'omni_notes';
  late final Box<OmniNote> _box;

  /// Must be called once at app startup.
  Future<void> init() async {
    if (!Hive.isAdapterRegistered(OmniNoteAdapter().typeId)) {
      Hive.registerAdapter(OmniNoteAdapter());
      Hive.registerAdapter(ZoneThemeAdapter());
      // register any other adapters...
    }
    _box = await Hive.openBox<OmniNote>(_boxName);
    notifyListeners();
  }

  /// All notes (including trashed)—useful for sync.
  Future<List<OmniNote>> get all async => _box.values.toList();

  /// Non-trashed notes.
  List<OmniNote> get notes =>
      _box.values.where((n) => !n.isTrashed).toList();

  /// Trashed notes.
  List<OmniNote> get trashedNotes =>
      _box.values.where((n) => n.isTrashed).toList();

  /// Lookup by ID.
  OmniNote? getNoteById(String id) => _box.get(id);
  OmniNote? getById(String id) => getNoteById(id);

  /// Save or update.
  Future<void> saveNote(OmniNote note) async {
    await _box.put(note.id, note);
    notifyListeners();
  }

  /// Alias for sync code.
  Future<void> save(OmniNote note) => saveNote(note);

  /// Soft-trash.
  Future<void> trashNote(String id) async {
    final note = _box.get(id);
    if (note != null && !note.isTrashed) {
      note.isTrashed = true;
      await note.save();
      notifyListeners();
    }
  }

  /// Restore from trash.
  Future<void> restoreNote(String id) async {
    final note = _box.get(id);
    if (note != null && note.isTrashed) {
      note.isTrashed = false;
      await note.save();
      notifyListeners();
    }
  }

  /// Permanently delete one.
  Future<void> deleteNote(String id) async {
    await _box.delete(id);
    notifyListeners();
  }

  /// Alias for sync code.
  Future<void> delete(String id) => deleteNote(id);

  /// Permanently delete multiple.
  Future<void> deletePermanent(List<String> ids) async {
    for (final id in ids) {
      await _box.delete(id);
    }
    notifyListeners();
  }
}
