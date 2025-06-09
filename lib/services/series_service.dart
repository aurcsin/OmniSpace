// lib/services/series_service.dart

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/series.dart';

class SeriesService extends ChangeNotifier {
  SeriesService._();
  static final SeriesService instance = SeriesService._();

  static const String _boxName = 'series_v2';
  static const String _oldBoxName = 'series';

  late Box<Series> _box;

  Future<void> init() async {
    if (await Hive.boxExists(_oldBoxName)) {
      final oldBox = await Hive.openBox<Series>(_oldBoxName);
      final newBox = await Hive.openBox<Series>(_boxName);
      for (final key in oldBox.keys) {
        final value = oldBox.get(key);
        if (value != null) {
          await newBox.put(key, value);
        }
      }
      await oldBox.deleteFromDisk();
      _box = newBox;
    } else {
      _box = await Hive.openBox<Series>(_boxName);
    }
    notifyListeners();
  }

  List<Series> get allSeries => _box.values.toList();

  Future<String> createSeries(String name) async {
    final s =
        Series(id: DateTime.now().millisecondsSinceEpoch.toString(), name: name);
    await _box.put(s.id, s);
    notifyListeners();
    return s.id;
  }
}
