import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../models/omni_note.dart';
import '../models/zone_theme.dart';  // ← now resolves

/// ChangeNotifier-backed Hive box for OmniNote.
class OmniNoteService extends ChangeNotifier {
  OmniNoteService._internal();
  static final OmniNoteService instance = OmniNoteService._internal();

  // Box name must match your tests:
  static const String _boxName = 'notes';
  late Box<OmniNote> _box;

  /// Call once at app startup.
  Future<void> init() async {
    if (!Hive.isAdapterRegistered(OmniNoteAdapter().typeId)) {
      Hive.registerAdapter(OmniNoteAdapter());
      Hive.registerAdapter(ZoneThemeAdapter());
      // register any other adapters here...
    }
    _box = await Hive.openBox<OmniNote>(_boxName);
    notifyListeners();
  }

  /// All non‐trashed notes.
  List<OmniNote> get notes =>
      _box.values.where((n) => !n.isTrashed).toList();

  /// Soft‐deleted notes.
  List<OmniNote> get trashedNotes =>
      _box.values.where((n) => n.isTrashed).toList();

  OmniNote? getNoteById(String id) => _box.get(id);
  OmniNote? getById(String id) => getNoteById(id);

  Future<void> saveNote(OmniNote note) async {
    await _box.put(note.id, note);
    notifyListeners();
  }

  Future<void> trashNote(String id) async {
    final note = _box.get(id);
    if (note != null && !note.isTrashed) {
      note.isTrashed = true;
      await note.save();
      notifyListeners();
    }
  }

  Future<void> restoreNote(String id) async {
    final note = _box.get(id);
    if (note != null && note.isTrashed) {
      note.isTrashed = false;
      await note.save();
      notifyListeners();
    }
  }

  Future<void> deleteNote(String id) async {
    await _box.delete(id);
    notifyListeners();
  }

  Future<void> deletePermanent(List<String> ids) async {
    for (final id in ids) {
      await _box.delete(id);
    }
    notifyListeners();
  }
}
