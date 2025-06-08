// lib/services/series_service.dart

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/series.dart';

class SeriesService extends ChangeNotifier {
  SeriesService._();
  static final SeriesService instance = SeriesService._();

  late Box<Series> _box;

  Future<void> init() async {
    _box = await Hive.openBox<Series>('series');
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
