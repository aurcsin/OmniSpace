// lib/services/note_collection_service.dart

import 'package:hive/hive.dart';
import 'package:omnispace/models/note_collection.dart';

class NoteCollectionService {
  NoteCollectionService._();
  static final instance = NoteCollectionService._();

  static const _boxName = 'note_collections';
  late Box<NoteCollection> _box;

  /// Must be called once at startup (before using `all` or other methods).
  Future<void> init() async {
    _box = await Hive.openBox<NoteCollection>(_boxName);
  }

  /// List of collections.
  List<NoteCollection> get all {
    if (!_box.isOpen) {
      throw StateError('NoteCollectionService.init() must be called before reading collections');
    }
    return _box.values.toList();
  }

  /// Create a new collection.
  Future<void> create({
    required String id,
    required String name,
    required List<String> noteIds,
  }) async {
    final collection = NoteCollection(id: id, name: name, noteIds: noteIds);
    await _box.put(id, collection);
  }

  /// Save/update an existing collection.
  Future<void> save(NoteCollection collection) async {
    await _box.put(collection.id, collection);
  }

  /// Delete a collection.
  Future<void> delete(String id) async {
    await _box.delete(id);
  }
}
