// lib/services/tracker_collection_service.dart

import 'package:hive/hive.dart';
import '../models/tracker_collection.dart';

class TrackerCollectionService {
  TrackerCollectionService._();
  static final instance = TrackerCollectionService._();

  static const _boxName = 'tracker_collections';
  late Box<TrackerCollection> _box;
  final List<TrackerCollection> _collections = [];

  /// Call once at app startup to open the Hive box and load collections.
  Future<void> init() async {
    _box = await Hive.openBox<TrackerCollection>(_boxName);
    _collections
      ..clear()
      ..addAll(_box.values);
  }

  /// All collections.
  List<TrackerCollection> get all => List.unmodifiable(_collections);

  /// Create a new collection.
  Future<void> create({
    required String id,
    required String name,
    List<String>? trackerIds,
    required String ownerId,
  }) async {
    final col = TrackerCollection(
      id: id,
      name: name,
      ownerId: ownerId,
      trackerIds: trackerIds ?? [],
    );
    await _box.put(id, col);
    _collections.add(col);
  }

  /// Add a tracker to a collection.
  Future<void> addToCollection(String collectionId, String trackerId) async {
    final col = _box.get(collectionId);
    if (col == null) return;
    if (!col.trackerIds.contains(trackerId)) {
      col.trackerIds.add(trackerId);
      await _box.put(collectionId, col);
      final idx = _collections.indexWhere((c) => c.id == collectionId);
      if (idx >= 0) _collections[idx] = col;
    }
  }

  /// Remove a tracker from a collection.
  Future<void> removeFromCollection(String collectionId, String trackerId) async {
    final col = _box.get(collectionId);
    if (col == null) return;
    col.trackerIds.remove(trackerId);
    await _box.put(collectionId, col);
    final idx = _collections.indexWhere((c) => c.id == collectionId);
    if (idx >= 0) _collections[idx] = col;
  }
}
