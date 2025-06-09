// File: lib/models/task.dart

import 'package:hive/hive.dart';

part 'task.g.dart';

/// A to-do task attached to a note.
@HiveType(typeId: 13)
class Task extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  bool completed;

  @HiveField(3)
  DateTime? dueDate;

  Task({
    required this.id,
    this.title = '',
    this.completed = false,
    this.dueDate,
  });

  /// Convert to JSON for sync or serialization.
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'completed': completed,
        'dueDate': dueDate?.toIso8601String(),
      };

  /// Create a Task from a JSON map.
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      completed: json['completed'] as bool,
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'] as String)
          : null,
    );
  }
}
