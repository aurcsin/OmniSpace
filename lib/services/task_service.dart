import 'package:flutter/foundation.dart';
import '../models/task.dart';

class TaskService extends ChangeNotifier {
  TaskService._();
  static final instance = TaskService._();

  final List<Task> _tasks = [];

  List<Task> get tasks => List.unmodifiable(_tasks);

  void add(Task task) {
    _tasks.add(task);
    notifyListeners();
  }

  void toggleComplete(Task task) {
    final i = _tasks.indexOf(task);
    if (i == -1) return;
    _tasks[i].isCompleted = !_tasks[i].isCompleted;
    notifyListeners();
  }

  void reorder(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) newIndex -= 1;
    final item = _tasks.removeAt(oldIndex);
    _tasks.insert(newIndex, item);
    notifyListeners();
  }
}