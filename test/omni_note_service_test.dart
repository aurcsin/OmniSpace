// lib/services/omni_note_service.dart

import 'package:hive/hive.dart';
import 'package:omnispace/models/omni_note.dart';

class OmniNoteService {
  OmniNoteService._();
  static final instance = OmniNoteService._();

  static const _boxName = 'omni_notes';
  late Box<OmniNote> _box;

  final List<OmniNote> _notes = [];

  /// Initialize Hive box and load existing notes.
  Future<void> init() async {
    _box = await Hive.openBox<OmniNote>(_boxName);
    _notes
      ..clear()
      ..addAll(_box.values);
  }

  /// All notes in memory.
  List<OmniNote> get notes => List.unmodifiable(_notes);

  /// Lookup by ID.
  OmniNote? getById(String id) {
    return _box.get(id);
  }

  /// Save or update a note both in Hive and memory.
  Future<void> save(OmniNote note) async {
    await _box.put(note.id, note);
    final idx = _notes.indexWhere((n) => n.id == note.id);
    if (idx >= 0) {
      _notes[idx] = note;
    } else {
      _notes.add(note);
    }
  }

  /// Alias for UI code.
  Future<void> saveNote(OmniNote note) => save(note);

  /// Permanently delete one or more notes.
  Future<void> deletePermanent(List<String> ids) async {
    for (final id in ids) {
      await _box.delete(id);
    }
    _notes.removeWhere((n) => ids.contains(n.id));
  }

  /// Delete a single note.
  Future<void> deleteNote(String id) async {
    await deletePermanent([id]);
  }

  /// Mark trashed/untrashed and persist.
  Future<void> setTrashed(String id, bool isTrashed) async {
    final note = _box.get(id);
    if (note != null) {
      note.isTrashed = isTrashed;
      await save(note);
    }
  }

  /// Convenience: get only trashed notes.
  List<OmniNote> get trashedNotes =>
      _notes.where((n) => n.isTrashed).toList();
}
