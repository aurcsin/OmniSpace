import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/goal.dart';

class GoalService extends ChangeNotifier {
  GoalService._();
  static final instance = GoalService._();

  static const String _boxName = 'goals';
  late Box<Goal> _box;

  final List<Goal> _goals = [];

  List<Goal> get goals => List.unmodifiable(_goals);

  Future<void> init() async {
    if (!Hive.isAdapterRegistered(GoalAdapter().typeId)) {
      Hive.registerAdapter(GoalAdapter());
    }
    _box = await Hive.openBox<Goal>(_boxName);
    _goals
      ..clear()
      ..addAll(_box.values);
    notifyListeners();
  }

  Future<void> save(Goal goal) async {
    await _box.put(goal.id, goal);
    final index = _goals.indexWhere((g) => g.id == goal.id);
    if (index == -1) {
      _goals.add(goal);
    } else {
      _goals[index] = goal;
    }
    notifyListeners();
  }

  Future<void> add(Goal goal) => save(goal);

  Future<void> delete(String id) async {
    await _box.delete(id);
    _goals.removeWhere((g) => g.id == id);
    notifyListeners();
  }

  void reorder(int oldIndex, int newIndex) {
    if (oldIndex == newIndex) {
      throw ArgumentError('oldIndex and newIndex must differ');
    }
    if (oldIndex < 0 || oldIndex >= _goals.length) {
      throw ArgumentError('oldIndex out of range');
    }
    if (newIndex < 0 || newIndex > _goals.length) {
      throw ArgumentError('newIndex out of range');
    }

    if (oldIndex < newIndex) newIndex -= 1;
    final item = _goals.removeAt(oldIndex);
    _goals.insert(newIndex, item);
    notifyListeners();
  }
}
