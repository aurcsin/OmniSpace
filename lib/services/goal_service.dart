import 'package:flutter/foundation.dart';
import '../models/goal.dart';

class GoalService extends ChangeNotifier {
  GoalService._();
  static final instance = GoalService._();

  final List<Goal> _goals = [];

  List<Goal> get goals => List.unmodifiable(_goals);

  void add(Goal goal) {
    _goals.add(goal);
    notifyListeners();
  }

  void reorder(int oldIndex, int newIndex) {
    assert(oldIndex >= 0 && oldIndex < _goals.length);
    assert(newIndex >= 0 && newIndex <= _goals.length);

    if (oldIndex < 0 || oldIndex >= _goals.length ||
        newIndex < 0 || newIndex > _goals.length) {
      throw ArgumentError('Invalid indices: oldIndex=$oldIndex, newIndex=$newIndex');
    }

    if (oldIndex < newIndex) newIndex -= 1;
    final item = _goals.removeAt(oldIndex);
    _goals.insert(newIndex, item);
    notifyListeners();
  }
}
