import 'package:hive/hive.dart';
import 'task.dart';

part 'task_bundle.g.dart';

@HiveType(typeId: 13)
class TaskBundle extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  List<Task> tasks;

  TaskBundle({required this.id, required this.name, List<Task>? tasks})
      : tasks = tasks ?? [];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'tasks': tasks.map((t) => t.toJson()).toList(),
      };

  factory TaskBundle.fromJson(Map<String, dynamic> json) => TaskBundle(
        id: json['id'] as String,
        name: json['name'] as String,
        tasks: (json['tasks'] as List<dynamic>? ?? [])
            .map((e) => Task.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
