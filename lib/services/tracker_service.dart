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
  late Box<Tracker> _box;

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

  // In-memory link map: noteId -> list of trackerIds
  final Map<String, List<String>> _links = {};

  /// Link a note to a tracker.
  Future<void> linkNote(String trackerId, String noteId) async {
    _links.putIfAbsent(noteId, () => []);
    if (!_links[noteId]!.contains(trackerId)) {
      _links[noteId]!.add(trackerId);
    }
    notifyListeners();
  }

  /// Unlink a tracker from a note.
  Future<void> unlinkNote(String trackerId, String noteId) async {
    _links[noteId]?.remove(trackerId);
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
