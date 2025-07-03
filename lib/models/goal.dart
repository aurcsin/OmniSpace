// File: lib/models/goal.dart

import 'package:hive/hive.dart';

part 'goal.g.dart';

/// A single step toward completing a goal.
@HiveType(typeId: 4)
class GoalStep {
  @HiveField(0)
  String id;

  @HiveField(1)
  String description;

  @HiveField(2)
  bool done;

  GoalStep({
    required this.id,
    required this.description,
    this.done = false,
  });
}

/// A checkpoint (sub‐goal) with its own target and steps.
@HiveType(typeId: 21)
class GoalCheckpoint {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  double target;

  @HiveField(3)
  double progress;

  @HiveField(4)
  List<GoalStep> steps;

  GoalCheckpoint({
    required this.id,
    required this.title,
    this.target = 1.0,
    this.progress = 0.0,
    this.steps = const [],
  });
}

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

  @HiveField(4)
  List<GoalStep> steps;

  @HiveField(5)
  List<GoalCheckpoint> checkpoints;

  Goal({
    required this.id,
    this.title = '',
    this.progress = 0.0,
    this.target = 1.0,
    this.steps = const [],
    this.checkpoints = const [],
  });

  /// Convert to JSON (include steps & checkpoints if you sync externally).
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'progress': progress,
        'target': target,
        'steps': steps
            .map((s) => {
                  'id': s.id,
                  'description': s.description,
                  'done': s.done,
                })
            .toList(),
        'checkpoints': checkpoints
            .map((c) => {
                  'id': c.id,
                  'title': c.title,
                  'target': c.target,
                  'progress': c.progress,
                  'steps': c.steps
                      .map((s) => {
                            'id': s.id,
                            'description': s.description,
                            'done': s.done,
                          })
                      .toList(),
                })
            .toList(),
      };

  /// Create from JSON.
  factory Goal.fromJson(Map<String, dynamic> json) => Goal(
        id: json['id'] as String,
        title: json['title'] as String,
        progress: (json['progress'] as num).toDouble(),
        target: (json['target'] as num).toDouble(),
        steps: (json['steps'] as List<dynamic>? ?? [])
            .map((e) => GoalStep(
                  id: e['id'] as String,
                  description: e['description'] as String,
                  done: e['done'] as bool,
                ))
            .toList(),
        checkpoints: (json['checkpoints'] as List<dynamic>? ?? [])
            .map((e) => GoalCheckpoint(
                  id: e['id'] as String,
                  title: e['title'] as String,
                  target: (e['target'] as num).toDouble(),
                  progress: (e['progress'] as num).toDouble(),
                  steps: (e['steps'] as List<dynamic>? ?? [])
                      .map((s) => GoalStep(
                            id: s['id'] as String,
                            description: s['description'] as String,
                            done: s['done'] as bool,
                          ))
                      .toList(),
                ))
            .toList(),
      );
}
