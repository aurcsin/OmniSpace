// File: lib/services/tracker_collection_service.dart

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/tracker_collection.dart';
import '../utils/id_generator.dart';

class TrackerCollectionService extends ChangeNotifier {
  TrackerCollectionService._();
  static final TrackerCollectionService instance =
      TrackerCollectionService._();

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

  Future<void> save(TrackerCollection collection) async {
    await _box.put(collection.id, collection);
    notifyListeners();
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
    notifyListeners();
  }

  /// Convenience: create a new collection with a generated id.
  Future<void> create(String name, List<String> trackerIds) async {
    final col = TrackerCollection(
      id: generateId(),
      name: name,
      trackerIds: trackerIds,
    );
    await save(col);
  }
}
