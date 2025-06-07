// lib/services/day_reflection_service.dart

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/day_reflection.dart';

class DayReflectionService extends ChangeNotifier {
  // Private constructor for singleton pattern
  DayReflectionService._();
  static final DayReflectionService instance = DayReflectionService._();

  late Box<DayReflection> _box;

  /// Initialize Hive box; call once at app startup (e.g. in main.dart)
  Future<void> init() async {
    _box = await Hive.openBox<DayReflection>('day_reflections');
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
