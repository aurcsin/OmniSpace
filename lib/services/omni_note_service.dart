import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../models/omni_note.dart';

/// A ChangeNotifier-backed Hive service for managing OmniNote objects.
class OmniNoteService extends ChangeNotifier {
  OmniNoteService._internal();
  static final OmniNoteService instance = OmniNoteService._internal();

  /// Unique Hive box name for notes.
  static const String _boxName = 'omni_notes';
  late final Box<OmniNote> _box;

  /// Initialize the service. Must be called once at app startup,
  /// after all Hive adapters have been registered.
  Future<void> init() async {
    _box = await Hive.openBox<OmniNote>(_boxName);
    notifyListeners();
  }

  /// Retrieve all notes, including trashed.
  List<OmniNote> get all => _box.values.toList();

  /// Only non-trashed.
  List<OmniNote> get notes =>
    _box.values.where((n) => !n.isTrashed).toList();

  /// Only trashed.
  List<OmniNote> get trashedNotes =>
    _box.values.where((n) => n.isTrashed).toList();

  /// Lookup by ID.
  OmniNote? getById(String id) => _box.get(id);

  /// Save or update.
  Future<void> saveNote(OmniNote note) async {
    await _box.put(note.id, note);
    notifyListeners();
  }

  /// Soft-trash.
  Future<void> trashNote(String id) async {
    final note = _box.get(id);
    if (note != null && !note.isTrashed) {
      note.isTrashed = true;
      await _box.put(id, note);
      notifyListeners();
    }
  }

  /// Restore.
  Future<void> restoreNote(String id) async {
    final note = _box.get(id);
    if (note != null && note.isTrashed) {
      note.isTrashed = false;
      await _box.put(id, note);
      notifyListeners();
    }
  }

  /// Permanently delete.
  Future<void> deleteNote(String id) async {
    await _box.delete(id);
    notifyListeners();
  }
}
