// File: lib/services/omni_note_service.dart

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../models/omni_note.dart';
import '../models/zone_theme.dart';  // ← import your enum so ZoneThemeAdapter is in scope

class OmniNoteService extends ChangeNotifier {
  OmniNoteService._internal();
  static final OmniNoteService instance = OmniNoteService._internal();

  // Must match the box name used in your tests
  static const String _boxName = 'notes';
  late Box<OmniNote> _box;

  /// Call once at app startup.
  Future<void> init() async {
    if (!Hive.isAdapterRegistered(OmniNoteAdapter().typeId)) {
      Hive.registerAdapter(OmniNoteAdapter());
      Hive.registerAdapter(ZoneThemeAdapter());  // ← now defined
      // register other adapters as needed...
    }
    _box = await Hive.openBox<OmniNote>(_boxName);
    notifyListeners();
  }

  /// All non-trashed notes.
  List<OmniNote> get notes =>
      _box.values.where((n) => !n.isTrashed).toList();

  /// Soft-deleted notes.
  List<OmniNote> get trashedNotes =>
      _box.values.where((n) => n.isTrashed).toList();

  /// Look up one note.
  OmniNote? getNoteById(String id) => _box.get(id);

  /// **Alias** so UI code (getById) continues to work unchanged.
  OmniNote? getById(String id) => getNoteById(id);

  /// Create or update.
  Future<void> saveNote(OmniNote note) async {
    await _box.put(note.id, note);
    notifyListeners();
  }

  /// Soft-trash one note.
  Future<void> trashNote(String id) async {
    final note = _box.get(id);
    if (note != null && !note.isTrashed) {
      note.isTrashed = true;
      await note.save();
      notifyListeners();
    }
  }

  /// Restore one soft-deleted note.
  Future<void> restoreNote(String id) async {
    final note = _box.get(id);
    if (note != null && note.isTrashed) {
      note.isTrashed = false;
      await note.save();
      notifyListeners();
    }
  }

  /// Permanently delete one note.
  Future<void> deleteNote(String id) async {
    await _box.delete(id);
    notifyListeners();
  }

  /// Permanently delete multiple notes.
  Future<void> deletePermanent(List<String> ids) async {
    for (final id in ids) {
      await _box.delete(id);
    }
    notifyListeners();
  }
}
