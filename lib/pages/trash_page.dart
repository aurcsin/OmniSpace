// lib/services/tracker_service.dart

import 'package:hive/hive.dart';
import 'package:omnispace/models/tracker.dart';
import 'package:omnispace/models/tracker_type.dart';

class TrackerService {
  TrackerService._();
  static final instance = TrackerService._();

  static const _boxName = 'trackers';
  late Box<Tracker> _box;
  final List<Tracker> _trackers = [];

  /// Call once at app startup.
  Future<void> init() async {
    _box = await Hive.openBox<Tracker>(_boxName);
    _trackers
      ..clear()
      ..addAll(_box.values);
  }

  /// All trackers in memory.
  List<Tracker> get all => List.unmodifiable(_trackers);

  /// Lookup by ID.
  Tracker? getById(String id) => _box.get(id);

  /// Alias for getById, used by tests.
  Tracker? byId(String id) => getById(id);

  /// Save or update a tracker.
  Future<void> save(Tracker tracker) async {
    await _box.put(tracker.id, tracker);
    final idx = _trackers.indexWhere((t) => t.id == tracker.id);
    if (idx >= 0) {
      _trackers[idx] = tracker;
    } else {
      _trackers.add(tracker);
    }
  }

  /// Create a new tracker (alias for save).
  Future<void> create(Tracker tracker) => save(tracker);

  /// Permanently delete trackers by their IDs.
  Future<void> deletePermanent(List<String> ids) async {
    for (final id in ids) {
      await _box.delete(id);
    }
    _trackers.removeWhere((t) => ids.contains(t.id));
  }

  /// Get trackers of a specific type in their current order.
  List<Tracker> ofType(TrackerType type) =>
      _trackers.where((t) => t.type == type).toList();

  /// Reorder a tracker by moving it to a new index within its type-specific list.
  void reorder(String id, int newIndex) {
    final list = ofType(_trackers.firstWhere((t) => t.id == id).type);
    final oldIndex = list.indexWhere((t) => t.id == id);
    if (oldIndex < 0) return;
    final tracker = list.removeAt(oldIndex);
    final insertIndex = newIndex.clamp(0, list.length);
    list.insert(insertIndex, tracker);

    // Now reflect this order back into the master _trackers list:
    // Remove all items of this type and re-insert in new order
    _trackers.removeWhere((t) => t.type == tracker.type);
    int masterInsert = 0;
    for (int i = 0; i < _trackers.length; i++) {
      if (_trackers[i].type.index > tracker.type.index) {
        masterInsert = i;
        break;
      }
      masterInsert = i + 1;
    }
    _trackers.insertAll(masterInsert, list);
    // Persisting full list ordering is optional
  }
}
