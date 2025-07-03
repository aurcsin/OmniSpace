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

  Future<void> init() async {
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

  Tracker? getById(String id) => _box.get(id);

  /// All trackers.
  List<Tracker> get all => _box.values.toList();

  /// Return trackers whose linkedNoteIds contains this ownerId.
  List<Tracker> linkedTo(String ownerId) =>
      all.where((t) => t.linkedNoteIds.contains(ownerId)).toList();

  /// Link a note to a tracker.
  Future<void> linkNote(String trackerId, String noteId) async {
    final t = _box.get(trackerId);
    if (t != null && !t.linkedNoteIds.contains(noteId)) {
      t.linkedNoteIds.add(noteId);
      await t.save();
      notifyListeners();
    }
  }

  /// Unlink a note from a tracker.
  Future<void> unlinkNote(String trackerId, String noteId) async {
    final t = _box.get(trackerId);
    if (t != null && t.linkedNoteIds.remove(noteId)) {
      await t.save();
      notifyListeners();
    }
  }

  /// Create a new tracker (alias for save).
  Future<void> create(Tracker t) => save(t);

  /// Delete permanently.
  Future<void> deleteTracker(String id) async {
    await _box.delete(id);
    notifyListeners();
  }

  /// Filter by type.
  List<Tracker> ofType(TrackerType type) =>
      all.where((t) => t.type == type).toList();
}
