// File: lib/services/tracker_service.dart

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/tracker.dart';
import '../models/tracker_type.dart';

/// A persistent tracker service using Hive for storage.
class TrackerService extends ChangeNotifier {
  TrackerService._internal();
  static final TrackerService instance = TrackerService._internal();

  static const String _boxName = 'trackers';
  static const String _linksBoxName = 'tracker_links';
  late Box<Tracker> _box;
  late Box<Map> _linksBox;

  /// Initialize Hive box. Call once at app startup.
  Future<void> init() async {
    // Register adapters if not already registered
    if (!Hive.isAdapterRegistered(TrackerAdapter().typeId)) {
      Hive.registerAdapter(TrackerAdapter());
    }
    if (!Hive.isAdapterRegistered(TrackerTypeAdapter().typeId)) {
      Hive.registerAdapter(TrackerTypeAdapter());
    }
    _box = await Hive.openBox<Tracker>(_boxName);
    _linksBox = await Hive.openBox<Map>(_linksBoxName);

    // Load stored links if present (migration-safe)
    final stored = _linksBox.get('links');
    if (stored is Map) {
      for (final entry in stored.entries) {
        _links[entry.key as String] =
            (entry.value as List).map((e) => e as String).toList();
      }
    } else {
      // First run or migrating from older version without persisted links
      await _linksBox.put('links', _links);
    }
    notifyListeners();
  }

  /// All trackers stored.
  List<Tracker> get all => _box.values.toList();

  /// Create or update a tracker.
  Future<void> save(Tracker tracker) async {
    await _box.put(tracker.id, tracker);
    notifyListeners();
  }

  /// Alias for creating a new tracker
  Future<void> create(Tracker tracker) => save(tracker);

  /// Delete a tracker by its id.
  Future<void> delete(String id) async {
    await _box.delete(id);
    notifyListeners();
  }

  /// Get trackers of a given type.
  List<Tracker> ofType(TrackerType type) =>
      _box.values.where((t) => t.type == type).toList();

  /// Reorder trackers of a specific type and persist the new order.
  Future<void> reorder(TrackerType type, int oldIndex, int newIndex) async {
    // Get the current list of trackers in insertion order
    final all = _box.values.toList();
    // Extract only trackers of the requested [type]
    final typed = all.where((t) => t.type == type).toList();

    if (oldIndex < 0 || oldIndex >= typed.length) return;

    // Clamp newIndex to the end of the typed list
    if (newIndex < 0) newIndex = 0;
    if (newIndex > typed.length) newIndex = typed.length;

    final item = typed.removeAt(oldIndex);
    typed.insert(newIndex, item);

    // Merge reordered typed trackers back into the master list
    int typedPos = 0;
    for (int i = 0; i < all.length; i++) {
      if (all[i].type == type) {
        all[i] = typed[typedPos++];
      }
    }

    // Persist the new order
    await _box.clear();
    for (final t in all) {
      await _box.put(t.id, t);
    }

    notifyListeners();
  }

  // In-memory link map: noteId -> list of trackerIds
  final Map<String, List<String>> _links = {};

  Future<void> _saveLinks() async {
    await _linksBox.put('links', _links);
  }

  /// Link a note to a tracker.
  Future<void> linkNote(String trackerId, String noteId) async {
    _links.putIfAbsent(noteId, () => []);
    if (!_links[noteId]!.contains(trackerId)) {
      _links[noteId]!.add(trackerId);
    }
    await _saveLinks();
    notifyListeners();
  }

  /// Unlink a tracker from a note.
  Future<void> unlinkNote(String trackerId, String noteId) async {
    _links[noteId]?.remove(trackerId);
    await _saveLinks();
    notifyListeners();
  }

  /// Get tracker IDs linked to a note.
  List<String> linkedTo(String noteId) => _links[noteId] ?? [];

  /// Get note IDs linked to a tracker.
  List<String> notesForTracker(String trackerId) {
    final ids = <String>[];
    _links.forEach((noteId, trackerIds) {
      if (trackerIds.contains(trackerId)) ids.add(noteId);
    });
    return ids;
  }
}
