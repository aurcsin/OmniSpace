// lib/services/day_reflection_service.dart

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/day_reflection.dart';

class DayReflectionService extends ChangeNotifier {
  // Private constructor for singleton pattern
  DayReflectionService._();
  static final DayReflectionService instance = DayReflectionService._();

  static const String _boxName = 'day_reflections_v2';
  static const String _oldBoxName = 'day_reflections';

  late Box<DayReflection> _box;

  /// Initialize Hive box; call once at app startup (e.g. in main.dart)
  Future<void> init() async {
    if (await Hive.boxExists(_oldBoxName)) {
      final oldBox = await Hive.openBox<DayReflection>(_oldBoxName);
      final newBox = await Hive.openBox<DayReflection>(_boxName);
      for (final key in oldBox.keys) {
        final value = oldBox.get(key);
        if (value != null) {
          await newBox.put(key, value);
        }
      }
      await oldBox.deleteFromDisk();
      _box = newBox;
    } else {
      _box = await Hive.openBox<DayReflection>(_boxName);
    }
    notifyListeners();
  }

  /// Returns all stored DayReflection objects
  List<DayReflection> get reflections => _box.values.toList();

  /// Retrieve an existing reflection by [dateKey] or create a new one
  DayReflection getOrCreate(String dateKey) {
    final existing = _box.get(dateKey);
    if (existing != null) return existing;

    final newReflection = DayReflection(dateKey: dateKey);
    _box.put(dateKey, newReflection);
    notifyListeners();
    return newReflection;
  }

  /// Save or update a [reflection] in the box
  Future<void> saveReflection(DayReflection reflection) async {
    await _box.put(reflection.dateKey, reflection);
    notifyListeners();
  }

  /// Optionally, delete a reflection for a given [dateKey]
  Future<void> deleteReflection(String dateKey) async {
    await _box.delete(dateKey);
    notifyListeners();
  }
}
