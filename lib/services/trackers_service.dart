// lib/services/trackers_service.dart

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/task.dart';
import '../models/goal.dart';
import '../models/event.dart';

class TrackersService extends ChangeNotifier {
  TrackersService._();
  static final instance = TrackersService._();

  late Box<Task> _taskBox;
  late Box<Goal> _goalBox;
  late Box<Event> _eventBox;

  bool _initialized = false;
  bool get isInitialized => _initialized;

  Future<void> init() async {
    if (_initialized) return;

    _taskBox = await Hive.openBox<Task>('tasks');
    _goalBox = await Hive.openBox<Goal>('goals');
    _eventBox = await Hive.openBox<Event>('events');
    _initialized = true;
    notifyListeners();
  }

  List<Task> get tasks => _taskBox.values.toList();
  List<Goal> get goals => _goalBox.values.toList();
  List<Event> get events => _eventBox.values.toList();

  Future<void> addTask(Task t) async {
    await _taskBox.add(t);
    notifyListeners();
  }

  Future<void> updateTask(Task t) async {
    await t.save();
    notifyListeners();
  }

  Future<void> deleteTask(Task t) async {
    await t.delete();
    notifyListeners();
  }

  Future<void> addGoal(Goal g) async {
    await _goalBox.add(g);
    notifyListeners();
  }

  Future<void> updateGoal(Goal g) async {
    await g.save();
    notifyListeners();
  }

  Future<void> deleteGoal(Goal g) async {
    await g.delete();
    notifyListeners();
  }

  Future<void> addEvent(Event e) async {
    await _eventBox.add(e);
    notifyListeners();
  }

  Future<void> updateEvent(Event e) async {
    await e.save();
    notifyListeners();
  }

  Future<void> deleteEvent(Event e) async {
    await e.delete();
    notifyListeners();
  }
}
