// File: lib/services/note_collection_service.dart

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/note_collection.dart';

/// Manages persistence of NoteCollection objects in Hive.
class NoteCollectionService extends ChangeNotifier {
  NoteCollectionService._internal();
  static final NoteCollectionService instance =
      NoteCollectionService._internal();

  static const _boxName = 'note_collections';
  late Box<NoteCollection> _box;

  /// Call once at startup.
  Future<void> init() async {
    if (!Hive.isAdapterRegistered(NoteCollectionAdapter().typeId)) {
      Hive.registerAdapter(NoteCollectionAdapter());
    }
    _box = await Hive.openBox<NoteCollection>(_boxName);
    notifyListeners();
  }

  /// All collections.
  List<NoteCollection> get all => _box.values.toList();

  /// Lookup.
  NoteCollection? getById(String id) => _box.get(id);

  /// Create a new collection.
  Future<void> create({
    required String id,
    required String name,
    List<String> noteIds = const [],
  }) async {
    final col = NoteCollection(id: id, name: name, noteIds: noteIds);
    await _box.put(id, col);
    notifyListeners();
  }

  /// Permanently delete.
  Future<void> delete(String id) async {
    await _box.delete(id);
    notifyListeners();
  }

  /// Add notes to an existing collection.
  Future<void> addNotes(String id, List<String> noteIds) async {
    final col = _box.get(id);
    if (col != null) {
      final updated = {...col.noteIds, ...noteIds}.toList();
      col.noteIds = updated;
      await col.save();
      notifyListeners();
    }
  }
}
