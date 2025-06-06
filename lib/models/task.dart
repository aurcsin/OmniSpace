import 'package:hive/hive.dart';

part 'task.g.dart';

@HiveType(typeId: 4)
class Task extends HiveObject {
  @HiveField(0)
  String description;

  @HiveField(1)
  bool isCompleted;

  /// e.g. "DAILY", "WEEKLY", "MONTHLY" or null for a one‐off
  @HiveField(2)
  String? recurringRule;

  Task({
    required this.description,
    this.isCompleted = false,
    this.recurringRule,
  });
}
