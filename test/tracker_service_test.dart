// lib/services/tracker_service.dart

import 'package:hive/hive.dart';
import 'package:omnispace/models/tracker.dart';

class TrackerService {
  TrackerService._();
  static final instance = TrackerService._();

  static const _boxName = 'trackers';
  late Box<Tracker> _box;
  final List<Tracker> _trackers = [];

  /// Call once at app startup to open Hive box and load existing trackers.
  Future<void> init() async {
    _box = await Hive.openBox<Tracker>(_boxName);
    _trackers
      ..clear()
      ..addAll(_box.values);
  }

  /// All trackers in memory.
  List<Tracker> get all => List.unmodifiable(_trackers);

  /// Lookup by ID (alias for byId).
  Tracker? getById(String id) => _box.get(id);

  /// Alias for getById, used by tests.
  Tracker? byId(String id) => getById(id);

  /// Save or update a tracker both in Hive and memory.
  Future<void> save(Tracker tracker) async {
    await _box.put(tracker.id, tracker);
    final idx = _trackers.indexWhere((t) => t.id == tracker.id);
    if (idx >= 0) {
      _trackers[idx] = tracker;
    } else {
      _trackers.add(tracker);
    }
  }

  /// Permanently delete trackers by their IDs.
  Future<void> deletePermanent(List<String> ids) async {
    for (final id in ids) {
      await _box.delete(id);
    }
    _trackers.removeWhere((t) => ids.contains(t.id));
  }
}
