// lib/services/tracker_collection_service.dart

import 'package:hive/hive.dart';
import '../models/tracker_collection.dart';

class TrackerCollectionService {
  // Singleton pattern
  TrackerCollectionService._internal();
  static final TrackerCollectionService instance = TrackerCollectionService._internal();

  Box<TrackerCollection>? _box;

  /// Initialize the service by opening the Hive box.
  Future<void> init() async {
    await _collectionsBox;
  }

  Future<Box<TrackerCollection>> get _collectionsBox async {
    if (_box != null) return _box!;
    _box = await Hive.openBox<TrackerCollection>('trackerCollections');
    return _box!;
  }

  /// Returns all saved collections
  Future<List<TrackerCollection>> get all async {
    final box = await _collectionsBox;
    return box.values.toList();
  }

  /// Saves or updates a collection
  Future<void> save(TrackerCollection collection) async {
    final box = await _collectionsBox;
    await box.put(collection.id, collection);
  }

  /// Deletes a collection by its ID
  Future<void> delete(String id) async {
    final box = await _collectionsBox;
    await box.delete(id);
  }
}
