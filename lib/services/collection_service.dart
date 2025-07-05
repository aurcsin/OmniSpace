// lib/services/collection_service.dart

import 'package:hive/hive.dart';
import 'package:omnispace/models/collection.dart';

class CollectionService {
  static final instance = CollectionService._();
  CollectionService._();

  static const _boxName = 'collections';
  late Box<Collection> _box;

  Future<void> init() async {
    _box = await Hive.openBox<Collection>(_boxName);
  }

  List<Collection> get all => _box.values.toList();

  Future<void> create(Collection c) => _box.put(c.id, c);

  Future<void> save(Collection c) => _box.put(c.id, c);

  Future<void> delete(String id) => _box.delete(id);

  Collection? getById(String id) => _box.get(id);

  List<Collection> ofType(String itemType) =>
    all.where((c) => c.itemType == itemType).toList();

  Future<void> addToCollection(String colId, String itemId) async {
    final c = _box.get(colId);
    if (c == null) return;
    if (!c.itemIds.contains(itemId)) {
      c.itemIds.add(itemId);
      await c.save();
    }
  }
}
