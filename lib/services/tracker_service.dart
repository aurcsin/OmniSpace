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

  /// In‐memory owner→tracker map (notes, projects, etc).
  final Map<String, List<String>> _ownerLinks = {};

  /// Call this once at app startup.
  Future<void> init() async {
    // Register adapters only once
    if (!Hive.isAdapterRegistered(TrackerAdapter().typeId)) {
      Hive.registerAdapter(TrackerAdapter());
    }
    if (!Hive.isAdapterRegistered(TrackerTypeAdapter().typeId)) {
      Hive.registerAdapter(TrackerTypeAdapter());
    }

    _box = await Hive.openBox<Tracker>(_boxName);
    notifyListeners();
  }

  /// All non‐trashed trackers.
  List<Tracker> get all =>
      _box.values.where((t) => !t.isTrashed).toList();

  /// Soft‐deleted trackers.
  List<Tracker> get trashed =>
      _box.values.where((t) => t.isTrashed).toList();

  /// Lookup by ID.
  Tracker? byId(String id) => _box.get(id);

  /// Create or update.
  Future<void> save(Tracker tracker) async {
    await _box.put(tracker.id, tracker);
    notifyListeners();
  }

  /// Alias so tests using `.create(...)` still pass.
  Future<void> create(Tracker tracker) => save(tracker);

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

  /// Soft‐trash one tracker.
  Future<void> trashTracker(String id) async {
    final t = _box.get(id);
    if (t != null && !t.isTrashed) {
      t.isTrashed = true;
      await t.save();
      notifyListeners();
    }
  }

  /// Restore one soft‐deleted tracker.
  Future<void> restoreTracker(String id) async {
    final t = _box.get(id);
    if (t != null && t.isTrashed) {
      t.isTrashed = false;
      await t.save();
      notifyListeners();
    }
  }

  /// Return all trackers of a given type (for tests using `.ofType(...)`).
  List<Tracker> ofType(TrackerType type) =>
      all.where((t) => t.type == type).toList();

  // --------------------------------------------------------------------
  // Owner–linking (notes, projects, etc.)
  // --------------------------------------------------------------------

  /// Link a tracker under a given owner (note, project, etc).
  Future<void> linkOwner(String trackerId, String ownerId) async {
    _ownerLinks.putIfAbsent(ownerId, () => []);
    if (!_ownerLinks[ownerId]!.contains(trackerId)) {
      _ownerLinks[ownerId]!.add(trackerId);
      notifyListeners();
    }
  }

  /// Unlink a tracker from that owner.
  Future<void> unlinkOwner(String trackerId, String ownerId) async {
    _ownerLinks[ownerId]?.remove(trackerId);
    notifyListeners();
  }

  /// Convenience aliases for notes:
  Future<void> linkNote(String trackerId, String noteId) =>
      linkOwner(trackerId, noteId);

  Future<void> unlinkNote(String trackerId, String noteId) =>
      unlinkOwner(trackerId, noteId);

  /// Get all tracker IDs linked under that owner.
  List<String> trackerIdsForOwner(String ownerId) =>
      List.unmodifiable(_ownerLinks[ownerId] ?? []);

  /// Alias used by UI code.
  List<String> linkedTo(String ownerId) =>
      trackerIdsForOwner(ownerId);
}
