// File: lib/services/tracker_service.dart

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/tracker.dart';
import '../models/tracker_type.dart';

class TrackerService extends ChangeNotifier {
  TrackerService._internal();
  static final TrackerService instance = TrackerService._internal();

  static const String _boxName = 'trackers';
  late Box<Tracker> _box;

  /// In-memory map: ownerId → list of trackerIds
  final Map<String, List<String>> _ownerLinks = {};

  /// Call once at app startup.
  Future<void> init() async {
    // Register adapters if not already done
    if (!Hive.isAdapterRegistered(TrackerAdapter().typeId)) {
      Hive.registerAdapter(TrackerAdapter());
      Hive.registerAdapter(TrackerTypeAdapter());
    }
    // Open the box
    _box = await Hive.openBox<Tracker>(_boxName);
    notifyListeners();
  }

  /// All non-deleted trackers.
  List<Tracker> get all =>
      _box.values.where((t) => !t.isTrashed).toList();

  /// Soft-deleted trackers.
  List<Tracker> get trashed =>
      _box.values.where((t) => t.isTrashed).toList();

  /// Lookup by ID.
  Tracker? byId(String id) => _box.get(id);

  /// Create or update.
  Future<void> save(Tracker tracker) async {
    await _box.put(tracker.id, tracker);
    notifyListeners();
  }

  /// **New**: Alias for tests that expect a `.create(...)` method
  Future<void> create(Tracker tracker) => save(tracker);

  /// Soft-trash one tracker.
  Future<void> trashTracker(String id) async {
    final t = _box.get(id);
    if (t != null && !t.isTrashed) {
      t.isTrashed = true;
      await t.save();
      notifyListeners();
    }
  }

  /// Restore one soft-deleted tracker.
  Future<void> restoreTracker(String id) async {
    final t = _box.get(id);
    if (t != null && t.isTrashed) {
      t.isTrashed = false;
      await t.save();
      notifyListeners();
    }
  }

  /// Permanently delete one tracker.
  Future<void> deleteTracker(String id) async {
    await _box.delete(id);
    notifyListeners();
  }

  /// Permanently delete multiple.
  Future<void> deletePermanent(List<String> ids) async {
    for (final id in ids) {
      await _box.delete(id);
    }
    notifyListeners();
  }

  /// **New**: Return all trackers of a given type, for tests using `.ofType(...)`
  List<Tracker> ofType(TrackerType type) =>
      all.where((t) => t.type == type).toList();

  // --------------------------------------------------------------------
  // Owner–linking map (notes, projects, etc.)
  // --------------------------------------------------------------------

  /// Link a tracker under a given owner (note, collection, etc).
  Future<void> linkOwner(String trackerId, String ownerId) async {
    _ownerLinks.putIfAbsent(ownerId, () => []);
    if (!_ownerLinks[ownerId]!.contains(trackerId)) {
      _ownerLinks[ownerId]!.add(trackerId);
      notifyListeners();
    }
  }

  /// Convenience alias for linking trackers to notes.
  Future<void> linkNote(String trackerId, String noteId) =>
      linkOwner(trackerId, noteId);

  /// Unlink a tracker from that owner.
  Future<void> unlinkOwner(String trackerId, String ownerId) async {
    _ownerLinks[ownerId]?.remove(trackerId);
    notifyListeners();
  }

  /// Convenience alias for unlinking trackers from notes.
  Future<void> unlinkNote(String trackerId, String noteId) =>
      unlinkOwner(trackerId, noteId);

  /// Get all tracker IDs linked under that owner.
  List<String> trackerIdsForOwner(String ownerId) =>
      List.unmodifiable(_ownerLinks[ownerId] ?? []);

  /// Alias used by UI code.
  List<String> linkedTo(String noteId) => trackerIdsForOwner(noteId);
}
