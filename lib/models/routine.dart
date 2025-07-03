// File: lib/models/routine.dart

import 'package:hive/hive.dart';

part 'routine.g.dart';

/// A recurring habit or activity with an optional start time and recurrence pattern.
@HiveType(typeId: 9)
class Routine extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String? description;

  /// When this routine first kicks off
  @HiveField(3)
  DateTime? start;

  /// e.g. 'daily', 'weekly', 'every Mon,Wed,Fri', or a cron-like string
  @HiveField(4)
  String? frequency;

  /// Optional manual list of dates (ISO strings) on which to run
  @HiveField(5)
  List<String>? customDates;

  /// IDs of notes you've linked to this routine
  @HiveField(6)
  List<String>? linkedNoteIds;

  /// IDs of other trackers connected to this routine
  @HiveField(7)
  List<String>? linkedTrackerIds;

  /// Mark a routine run as completed
  @HiveField(8)
  bool isCompleted;

  @HiveField(9)
  DateTime createdAt;

  @HiveField(10)
  DateTime lastUpdated;

  Routine({
    required this.id,
    required this.title,
    this.description,
    this.start,
    this.frequency,
    this.customDates,
    this.linkedNoteIds,
    this.linkedTrackerIds,
    this.isCompleted = false,
    DateTime? createdAt,
    DateTime? lastUpdated,
  })  : createdAt = createdAt ?? DateTime.now(),
        lastUpdated = lastUpdated ?? createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'start': start?.toIso8601String(),
        'frequency': frequency,
        'customDates': customDates,
        'linkedNoteIds': linkedNoteIds,
        'linkedTrackerIds': linkedTrackerIds,
        'isCompleted': isCompleted,
        'createdAt': createdAt.toIso8601String(),
        'lastUpdated': lastUpdated.toIso8601String(),
      };

  factory Routine.fromJson(Map<String, dynamic> json) => Routine(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String?,
        start: json['start'] != null ? DateTime.parse(json['start']) : null,
        frequency: json['frequency'] as String?,
        customDates: (json['customDates'] as List<dynamic>?)
            ?.map((d) => d as String)
            .toList(),
        linkedNoteIds: (json['linkedNoteIds'] as List<dynamic>?)
            ?.map((n) => n as String)
            .toList(),
        linkedTrackerIds: (json['linkedTrackerIds'] as List<dynamic>?)
            ?.map((t) => t as String)
            .toList(),
        isCompleted: json['isCompleted'] as bool? ?? false,
        createdAt: DateTime.parse(json['createdAt'] as String),
        lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      );
}
