import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../models/tracker.dart';
import '../models/tracker_type.dart';

class TrackerService extends ChangeNotifier {
  TrackerService._internal();
  static final TrackerService instance = TrackerService._internal();

  static const String _boxName = 'trackers';
  late Box<Tracker> _box;

  /// ownerId → trackerIds (for linking trackers to notes, projects, etc.)
  final Map<String, List<String>> _ownerLinks = {};

  /// Call once at app startup.
  Future<void> init() async {
    if (!Hive.isAdapterRegistered(TrackerAdapter().typeId)) {
      Hive.registerAdapter(TrackerAdapter());
      Hive.registerAdapter(TrackerTypeAdapter());
    }
    _box = await Hive.openBox<Tracker>(_boxName);
    notifyListeners();
  }

  /// All non-trashed trackers.
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

  /// Soft-trash.
  Future<void> trashTracker(String id) async {
    final t = _box.get(id);
    if (t != null && !t.isTrashed) {
      t.isTrashed = true;
      await t.save();
      notifyListeners();
    }
  }

  /// Restore a trashed one.
  Future<void> restoreTracker(String id) async {
    final t = _box.get(id);
    if (t != null && t.isTrashed) {
      t.isTrashed = false;
      await t.save();
      notifyListeners();
    }
  }

  /// Permanently delete.
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

  /// Convenience to get by type.
  List<Tracker> ofType(TrackerType type) =>
      all.where((t) => t.type == type).toList();

  // ────────────────────────────────────────────────────────
  // Owner-linking API (notes, projects, etc.)
  // ────────────────────────────────────────────────────────

  Future<void> linkOwner(String trackerId, String ownerId) async {
    _ownerLinks.putIfAbsent(ownerId, () => []);
    if (!_ownerLinks[ownerId]!.contains(trackerId)) {
      _ownerLinks[ownerId]!.add(trackerId);
      notifyListeners();
    }
  }

  Future<void> unlinkOwner(String trackerId, String ownerId) async {
    _ownerLinks[ownerId]?.remove(trackerId);
    notifyListeners();
  }

  /// Link/unlink shortcuts for notes
  Future<void> linkNote(String trackerId, String noteId) =>
      linkOwner(trackerId, noteId);
  Future<void> unlinkNote(String trackerId, String noteId) =>
      unlinkOwner(trackerId, noteId);

  /// Get all tracker IDs linked under that owner.
  List<String> linkedTo(String ownerId) =>
      List.unmodifiable(_ownerLinks[ownerId] ?? []);
}
