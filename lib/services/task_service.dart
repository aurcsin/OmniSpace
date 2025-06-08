import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/task.dart';
import '../models/omni_note.dart';
import 'omni_note_service.dart';

class TaskService extends ChangeNotifier {
  TaskService._();
  static final instance = TaskService._();

  late Box<Task> _box;

  Future<void> init() async {
    _box = await Hive.openBox<Task>('tasks');
    notifyListeners();
  }

  List<MapEntry<OmniNote?, Task>> get aggregatedTasks {
    final items = <MapEntry<OmniNote?, Task>>[];
    if (_box.isOpen) {
      items.addAll(_box.values.map((t) => MapEntry<OmniNote?, Task>(null, t)));
    }
    for (final note in OmniNoteService.instance.notes) {
      final tasks = note.tasks ?? [];
      for (final t in tasks) {
        items.add(MapEntry(note, t));
      }
    }
    return items;
  }

  Future<void> addTask(Task task, {OmniNote? note}) async {
    if (note == null) {
      await _box.add(task);
    } else {
      note.tasks ??= [];
      note.tasks!.add(task);
      await note.save();
    }
    notifyListeners();
  }

  Future<void> toggleCompletion(MapEntry<OmniNote?, Task> entry) async {
    entry.value.isCompleted = !entry.value.isCompleted;
    if (entry.key == null) {
      await entry.value.save();
    } else {
      await entry.key!.save();
    }
    notifyListeners();
  }
}
