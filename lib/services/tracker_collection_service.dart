// File: lib/services/tracker_collection_service.dart

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../models/tracker_collection.dart';

class TrackerCollectionService extends ChangeNotifier {
  TrackerCollectionService._internal();
  static final TrackerCollectionService instance =
      TrackerCollectionService._internal();

  static const String _boxName = 'tracker_collections';
  late Box<TrackerCollection> _box;

  /// Initialize Hive box and notify listeners.
  Future<void> init() async {
    if (!Hive.isAdapterRegistered(TrackerCollectionAdapter().typeId)) {
      Hive.registerAdapter(TrackerCollectionAdapter());
    }
    _box = await Hive.openBox<TrackerCollection>(_boxName);
    notifyListeners();
  }

  /// All tracker collections.
  List<TrackerCollection> get all => _box.values.toList();

  /// Create a new collection and notify.
  Future<void> create({
    required String id,
    required String name,
    required String ownerId,
    List<String> trackerIds = const [],
  }) async {
    final col = TrackerCollection(
      id: id,
      name: name,
      ownerId: ownerId,
      trackerIds: trackerIds,
    );
    await _box.put(col.id, col);
    notifyListeners();
  }

  /// Save or update an existing collection.
  Future<void> save(TrackerCollection col) async {
    await _box.put(col.id, col);
    notifyListeners();
  }

  /// Delete a collection by id.
  Future<void> delete(String id) async {
    await _box.delete(id);
    notifyListeners();
  }

  /// Delete multiple collections at once.
  Future<void> deleteBatch(List<String> ids) async {
    for (final id in ids) {
      await _box.delete(id);
    }
    notifyListeners();
  }

  /// Add a single tracker to a collection.
  Future<void> addToCollection(String colId, String trackerId) async {
    final col = _box.get(colId);
    if (col != null && !col.trackerIds.contains(trackerId)) {
      col.trackerIds.add(trackerId);
      await save(col);
    }
  }
}
