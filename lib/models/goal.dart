// File: lib/models/goal.dart

import 'package:hive/hive.dart';

part 'goal.g.dart';

/// A progress-based goal attached to a note.
@HiveType(typeId: 4)
class Goal extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  double progress;

  @HiveField(3)
  double target;

  Goal({
    required this.id,
    this.title = '',
    this.progress = 0.0,
    this.target = 1.0,
  });

  /// Convert to JSON for sync or serialization.
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'progress': progress,
        'target': target,
      };

  /// Create a Goal from a JSON map.
  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'] as String,
      title: json['title'] as String,
      progress: (json['progress'] as num).toDouble(),
      target: (json['target'] as num).toDouble(),
    );
  }
}
