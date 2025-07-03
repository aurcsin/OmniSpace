// File: lib/services/tracker_service.dart

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../models/tracker.dart';
import '../models/tracker_type.dart';

class TrackerService extends ChangeNotifier {
  TrackerService._internal();
  static final TrackerService instance = TrackerService._internal();

  static const _boxName = 'trackers';
  late final Box<Tracker> _box;
  bool _initialized = false; // ← guard

  /// Call once at startup.
  Future<void> init() async {
    if (_initialized) return;           // ← no-op on subsequent calls
    _initialized = true;

    if (!Hive.isAdapterRegistered(TrackerAdapter().typeId)) {
      Hive.registerAdapter(TrackerAdapter());
    }
    _box = await Hive.openBox<Tracker>(_boxName);
    notifyListeners();
  }

  /// Save or update.
  Future<void> save(Tracker t) async {
    await _box.put(t.id, t);
    notifyListeners();
  }

  /// Alias for `save`.
  Future<void> create(Tracker t) => save(t);

  /// Permanently delete.
  Future<void> deleteTracker(String id) async {
    await _box.delete(id);
    notifyListeners();
  }

  /// Soft‐trash.
  Future<void> trashTracker(String id) async {
    final t = _box.get(id);
    if (t != null && !t.isTrashed) {
      t.isTrashed = true;
      await t.save();
      notifyListeners();
    }
  }

  /// Restore from trash.
  Future<void> restoreTracker(String id) async {
    final t = _box.get(id);
    if (t != null && t.isTrashed) {
      t.isTrashed = false;
      await t.save();
      notifyListeners();
    }
  }

  /// Lookup by ID.
  Tracker? getById(String id) => _box.get(id);

  /// Alias for tests & legacy code.
  Tracker? byId(String id) => getById(id);

  /// All trackers (including trashed).
  List<Tracker> get all => _box.values.toList();

  /// Only non-trashed.
  List<Tracker> get active =>
      _box.values.where((t) => !t.isTrashed).toList();

  /// Only trashed.
  List<Tracker> get trashed =>
      _box.values.where((t) => t.isTrashed).toList();

  /// Return trackers of a given type.
  List<Tracker> ofType(TrackerType type) =>
      _box.values.where((t) => t.type == type).toList();

  /// Return trackers linked to a note.
  List<Tracker> linkedTo(String ownerId) =>
      all.where((t) => t.linkedNoteIds.contains(ownerId)).toList();

  /// Link/unlink APIs for OmniTrackerSelector
  Future<void> linkNote(String trackerId, String noteId) async {
    final t = _box.get(trackerId);
    if (t != null && !t.linkedNoteIds.contains(noteId)) {
      t.linkedNoteIds.add(noteId);
      await t.save();
      notifyListeners();
    }
  }

  Future<void> unlinkNote(String trackerId, String noteId) async {
    final t = _box.get(trackerId);
    if (t != null && t.linkedNoteIds.remove(noteId)) {
      await t.save();
      notifyListeners();
    }
  }
}
