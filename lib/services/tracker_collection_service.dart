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

  Future<void> init() async {
    if (!Hive.isAdapterRegistered(TrackerCollectionAdapter().typeId)) {
      Hive.registerAdapter(TrackerCollectionAdapter());
    }
    _box = await Hive.openBox<TrackerCollection>(_boxName);
    notifyListeners();
  }

  List<TrackerCollection> get all => _box.values.toList();

  Future<void> create({
    required String name,
    required String ownerId,
    required List<String> trackerIds,
  }) async {
    final id = UniqueKey().toString();
    final col = TrackerCollection(
      id: id,
      name: name,
      ownerId: ownerId,
      trackerIds: trackerIds,
    );
    await _box.put(id, col);
    notifyListeners();
  }

  Future<void> deletePermanent(String id) async {
    await _box.delete(id);
    notifyListeners();
  }

  /// Batch-add trackers to an existing collection
  Future<void> addTrackersToCollection(
      String collectionId, List<String> trackerIds) async {
    final col = _box.get(collectionId);
    if (col != null) {
      final existing = List<String>.from(col.trackerIds);
      for (var id in trackerIds) {
        if (!existing.contains(id)) existing.add(id);
      }
      col.trackerIds = existing;
      await _box.put(collectionId, col);
      notifyListeners();
    }
  }
}
