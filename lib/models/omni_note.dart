// File: lib/models/omni_note.dart

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import 'zone_theme.dart';
import 'attachment.dart';
import 'task.dart';
import 'goal.dart';
import 'event.dart';
import 'task_bundle.dart';
import 'goal_bundle.dart';
import 'event_bundle.dart';
import 'series_bundle.dart';

part 'omni_note.g.dart';

@HiveType(typeId: 0)
class OmniNote extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  String title;
  @HiveField(2)
  String subtitle;
  @HiveField(3)
  String content;
  @HiveField(4)
  ZoneTheme zone;
  @HiveField(5)
  String tags;
  @HiveField(6)
  int colorValue;
  @HiveField(7)
  String? mood;
  @HiveField(8)
  String? direction;
  @HiveField(9)
  String? projectId;
  @HiveField(10)
  String? recommendedTag;
  @HiveField(11)
  String? seriesId;
  @HiveField(12)
  List<Attachment> attachments;
  @HiveField(13)
  List<Task>? tasks;
  @HiveField(14)
  List<Goal>? goals;
  @HiveField(15)
  List<Event>? events;
  @HiveField(16)
  DateTime createdAt;
  @HiveField(17)
  DateTime lastUpdated;
  @HiveField(18)
  bool isPinned;
  @HiveField(19)
  List<GoalBundle>? goalBundles;
  @HiveField(20)
  List<EventBundle>? eventBundles;
  @HiveField(21)
  List<TaskBundle>? taskBundles;
  @HiveField(22)
  List<SeriesBundle>? seriesBundles;

  OmniNote({
    required this.id,
    this.title = '',
    this.subtitle = '',
    this.content = '',
    this.zone = ZoneTheme.Fusion,
    this.tags = '',
    this.colorValue = 0xFFFFFFFF,
    this.mood,
    this.direction,
    this.projectId,
    this.recommendedTag,
    this.seriesId,
    List<Attachment>? attachments,
    this.tasks,
    this.goals,
    this.events,
    this.goalBundles,
    this.eventBundles,
    this.taskBundles,
    this.seriesBundles,
    DateTime? createdAt,
    DateTime? lastUpdated,
    this.isPinned = false,
  })  : attachments = attachments ?? [],
        createdAt = createdAt ?? DateTime.now(),
        lastUpdated = lastUpdated ?? createdAt ?? DateTime.now();

  /// Serialize this note to JSON-compatible map.
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'content': content,
        'zone': describeEnum(zone),
        'tags': tags,
        'colorValue': colorValue,
        'mood': mood,
        'direction': direction,
        'projectId': projectId,
        'recommendedTag': recommendedTag,
        'seriesId': seriesId,
        'attachments': attachments.map((a) => a.toJson()).toList(),
        'tasks': tasks?.map((t) => t.toJson()).toList(),
        'goals': goals?.map((g) => g.toJson()).toList(),
        'events': events?.map((e) => e.toJson()).toList(),
        'goalBundles': goalBundles?.map((g) => g.toJson()).toList(),
        'eventBundles': eventBundles?.map((e) => e.toJson()).toList(),
        'taskBundles': taskBundles?.map((t) => t.toJson()).toList(),
        'seriesBundles': seriesBundles?.map((s) => s.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
        'lastUpdated': lastUpdated.toIso8601String(),
        'isPinned': isPinned,
      };

  /// Deserialize an OmniNote from JSON map.
  factory OmniNote.fromJson(Map<String, dynamic> json) => OmniNote(
        id: json['id'] as String,
        title: json['title'] as String,
        subtitle: json['subtitle'] as String,
        content: json['content'] as String,
        zone: ZoneTheme.values.firstWhere(
            (z) => describeEnum(z) == json['zone'] as String),
        tags: json['tags'] as String,
        colorValue: json['colorValue'] as int,
        mood: json['mood'] as String?,
        direction: json['direction'] as String?,
        projectId: json['projectId'] as String?,
        recommendedTag: json['recommendedTag'] as String?,
        seriesId: json['seriesId'] as String?,
        attachments: (json['attachments'] as List<dynamic>)
            .map((a) => Attachment.fromJson(a as Map<String, dynamic>))
            .toList(),
        tasks: (json['tasks'] as List<dynamic>?)
            ?.map((t) => Task.fromJson(t as Map<String, dynamic>))
            .toList(),
        goals: (json['goals'] as List<dynamic>?)
            ?.map((g) => Goal.fromJson(g as Map<String, dynamic>))
            .toList(),
        events: (json['events'] as List<dynamic>?)
            ?.map((e) => Event.fromJson(e as Map<String, dynamic>))
            .toList(),
        goalBundles: (json['goalBundles'] as List<dynamic>?)
            ?.map((g) => GoalBundle.fromJson(g as Map<String, dynamic>))
            .toList(),
        eventBundles: (json['eventBundles'] as List<dynamic>?)
            ?.map((e) => EventBundle.fromJson(e as Map<String, dynamic>))
            .toList(),
        taskBundles: (json['taskBundles'] as List<dynamic>?)
            ?.map((t) => TaskBundle.fromJson(t as Map<String, dynamic>))
            .toList(),
        seriesBundles: (json['seriesBundles'] as List<dynamic>?)
            ?.map((s) => SeriesBundle.fromJson(s as Map<String, dynamic>))
            .toList(),
        createdAt: DateTime.parse(json['createdAt'] as String),
        lastUpdated: DateTime.parse(json['lastUpdated'] as String),
        isPinned: json['isPinned'] as bool,
      );
}
