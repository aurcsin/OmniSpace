// File: lib/services/task_service.dart

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/task.dart';

/// Service to manage Task CRUD operations using Hive persistence.
class TaskService extends ChangeNotifier {
  TaskService._internal();
  static final TaskService instance = TaskService._internal();

  static const String _boxName = 'tasks';
  late Box<Task> _box;

  /// Initialize Hive box. Call once at app startup.
  Future<void> init() async {
    // Register adapter if not already
    if (!Hive.isAdapterRegistered(TaskAdapter().typeId)) {
      Hive.registerAdapter(TaskAdapter());
    }
    _box = await Hive.openBox<Task>(_boxName);
    notifyListeners();
  }

  /// All tasks.
  List<Task> get tasks => _box.values.toList();

  /// Create or update a task.
  Future<void> save(Task task) async {
    await _box.put(task.id, task);
    notifyListeners();
  }

  /// Delete a task by id.
  Future<void> delete(String id) async {
    await _box.delete(id);
    notifyListeners();
  }

  /// Mark a task as completed or not.
  Future<void> setTaskCompleted(Task task, bool completed) async {
    task.completed = completed;
    await task.save();
    notifyListeners();
  }
}
