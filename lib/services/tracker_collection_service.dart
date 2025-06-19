// File: lib/services/tracker_collection_service.dart

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/tracker_collection.dart';
import '../utils/id_generator.dart';

class TrackerCollectionService extends ChangeNotifier {
  TrackerCollectionService._internal();
  static final TrackerCollectionService instance =
      TrackerCollectionService._internal();

  static const String _boxName = 'tracker_collections';
  late Box<TrackerCollection> _box;

  Future<void> init() async {
    if (!Hive.isAdapterRegistered(TrackerCollectionAdapter().typeId)) {
      Hive.registerAdapter(TrackerCollectionAdapter());
    }
    _box = await Hive.openBox<TrackerCollection>(_boxName);
    notifyListeners();
  }

  /// All collections regardless of owner.
  List<TrackerCollection> get all => _box.values.toList();

  /// Collections belonging to a specific owner.
  List<TrackerCollection> collectionsForOwner(String ownerId) =>
      all.where((c) => c.ownerId == ownerId).toList();

  Future<void> save(TrackerCollection collection) async {
    await _box.put(collection.id, collection);
    notifyListeners();
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
    notifyListeners();
  }

  /// Convenience: create a new collection with a generated id.
  Future<void> create({
    required String name,
    required String ownerId,
    required List<String> trackerIds,
  }) async {
    final col = TrackerCollection(
      id: generateId(),
      name: name,
      ownerId: ownerId,
      trackerIds: trackerIds,
    );
    await save(col);
  }
}
