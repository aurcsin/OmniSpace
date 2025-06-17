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

  Future<void> init() async {
    if (!Hive.isAdapterRegistered(TrackerAdapter().typeId)) {
      Hive.registerAdapter(TrackerAdapter());
    }
    if (!Hive.isAdapterRegistered(TrackerTypeAdapter().typeId)) {
      Hive.registerAdapter(TrackerTypeAdapter());
    }
    _box = await Hive.openBox<Tracker>(_boxName);
    notifyListeners();
  }

  List<Tracker> get all =>
      _box.values.where((t) => !t.isTrashed).toList();

  List<Tracker> get trashedTrackers =>
      _box.values.where((t) => t.isTrashed).toList();

  Tracker? byId(String id) => _box.get(id);

  Future<void> save(Tracker tracker) async {
    await _box.put(tracker.id, tracker);
    notifyListeners();
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
    notifyListeners();
  }

  Future<void> trashTrackers(List<String> ids) async {
    for (final id in ids) {
      final t = _box.get(id);
      if (t != null && !t.isTrashed) {
        t.isTrashed = true;
        await t.save();
      }
    }
    notifyListeners();
  }

  Future<void> restoreTrackers(List<String> ids) async {
    for (final id in ids) {
      final t = _box.get(id);
      if (t != null && t.isTrashed) {
        t.isTrashed = false;
        await t.save();
      }
    }
    notifyListeners();
  }

  Future<void> deletePermanent(List<String> ids) async {
    for (final id in ids) {
      await _box.delete(id);
    }
    notifyListeners();
  }

  /// Link a tracker under a given owner (note, collection, etc).
  Future<void> linkOwner(String trackerId, String ownerId) async {
    _ownerLinks.putIfAbsent(ownerId, () => []);
    if (!_ownerLinks[ownerId]!.contains(trackerId)) {
      _ownerLinks[ownerId]!.add(trackerId);
      notifyListeners();
    }
  }

  /// Unlink a tracker from that owner
  Future<void> unlinkOwner(String trackerId, String ownerId) async {
    _ownerLinks[ownerId]?.remove(trackerId);
    notifyListeners();
  }

  /// Get all tracker IDs linked under that owner
  List<String> trackerIdsForOwner(String ownerId) =>
      List.unmodifiable(_ownerLinks[ownerId] ?? []);
}
