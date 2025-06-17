// File: lib/services/omni_note_service.dart

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/omni_note.dart';
import '../models/attachment.dart';
import '../models/task.dart';
import '../models/goal.dart';
import '../models/event.dart';

class OmniNoteService extends ChangeNotifier {
  OmniNoteService._();
  static final OmniNoteService instance = OmniNoteService._();

  static const String _boxName = 'notes';
  late Box<OmniNote> _box;

  Future<void> init() async {
    if (!Hive.isAdapterRegistered(OmniNoteAdapter().typeId)) {
      Hive.registerAdapter(OmniNoteAdapter());
    }
    if (!Hive.isAdapterRegistered(ZoneThemeAdapter().typeId)) {
      Hive.registerAdapter(ZoneThemeAdapter());
    }
    if (!Hive.isAdapterRegistered(AttachmentAdapter().typeId)) {
      Hive.registerAdapter(AttachmentAdapter());
    }
    if (!Hive.isAdapterRegistered(TaskAdapter().typeId)) {
      Hive.registerAdapter(TaskAdapter());
    }
    if (!Hive.isAdapterRegistered(GoalAdapter().typeId)) {
      Hive.registerAdapter(GoalAdapter());
    }
    if (!Hive.isAdapterRegistered(EventAdapter().typeId)) {
      Hive.registerAdapter(EventAdapter());
    }

    _box = await Hive.openBox<OmniNote>(_boxName);
    notifyListeners();
  }

  Future<void> _ensureInit() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await init();
    }
  }

  /// All non-trashed notes.
  List<OmniNote> get notes =>
      _box.values.where((n) => !n.isTrashed).toList();

  /// All trashed notes.
  List<OmniNote> get trashedNotes =>
      _box.values.where((n) => n.isTrashed).toList();

  /// Reload (no-op for Hive, but triggers listeners).
  Future<void> loadAllNotes() async {
    await _ensureInit();
    notifyListeners();
  }

  /// Search over non-trashed notes.
  Future<List<OmniNote>> searchNotes(String query) async {
    await _ensureInit();
    final q = query.toLowerCase();
    return _box.values
        .where((n) => !n.isTrashed)
        .where((n) =>
            n.title.toLowerCase().contains(q) ||
            n.content.toLowerCase().contains(q) ||
            n.tags.toLowerCase().contains(q))
        .toList();
  }

  /// Get a note by its id (or null if missing).
  OmniNote? getNoteById(String id) {
    if (!_box.isOpen) return null;
    return _box.get(id);
  }

  /// Create or update.
  Future<void> saveNote(OmniNote note) async {
    await _ensureInit();
    await _box.put(note.id, note);
    notifyListeners();
  }

  /// Hard‐delete by id.
  Future<void> deleteNoteById(String id) async {
    await _ensureInit();
    await _box.delete(id);
    notifyListeners();
  }

  /// Mark notes trashed.
  Future<void> trashNotes(List<String> ids) async {
    await _ensureInit();
    for (final id in ids) {
      final n = _box.get(id);
      if (n != null && !n.isTrashed) {
        n.isTrashed = true;
        await n.save();
      }
    }
    notifyListeners();
  }

  /// Restore trashed notes.
  Future<void> restoreNotes(List<String> ids) async {
    await _ensureInit();
    for (final id in ids) {
      final n = _box.get(id);
      if (n != null && n.isTrashed) {
        n.isTrashed = false;
        await n.save();
      }
    }
    notifyListeners();
  }

  /// Permanently delete a batch of notes.
  Future<void> deletePermanent(List<String> ids) async {
    await _ensureInit();
    for (final id in ids) {
      await _box.delete(id);
    }
    notifyListeners();
  }

  // — attachment helpers omitted —
}
