// lib/models/omni_note.dart

import 'package:hive/hive.dart';
import 'attachment.dart';
import 'task.dart';
import 'goal.dart';
import 'event.dart';

part 'omni_note.g.dart';

/// The six “zones” of your OmniSpace world.
@HiveType(typeId: 10)
enum ZoneTheme {
  @HiveField(0)
  Air,
  @HiveField(1)
  Earth,
  @HiveField(2)
  Fire,
  @HiveField(3)
  Water,
  @HiveField(4)
  Void,
  @HiveField(5)
  Fusion,
}

/// Your core note model.
@HiveType(typeId: 0)
class OmniNote extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String subtitle;

  @HiveField(2)
  String content;

  @HiveField(3)
  ZoneTheme zone;

  @HiveField(4)
  String tags;

  @HiveField(5)
  int colorValue;

  @HiveField(6)
  String? mood;

  @HiveField(7)
  String? direction;

  @HiveField(8)
  String? projectId;

  @HiveField(9)
  String? recommendedTag;

  @HiveField(10)
  List<Attachment> attachments;

  @HiveField(11)
  List<Task>? tasks;

  @HiveField(12)
  List<Goal>? goals;

  @HiveField(13)
  List<Event>? events;

  @HiveField(14)
  DateTime createdAt;

  OmniNote({
    required this.title,
    required this.subtitle,
    required this.content,
    this.zone = ZoneTheme.Fusion,
    this.tags = '',
    this.colorValue = 0xFFFFFFFF,
    this.mood,
    this.direction,
    this.projectId,
    this.recommendedTag,
    List<Attachment>? attachments,
    this.tasks,
    this.goals,
    this.events,
    DateTime? createdAt,
  })  : attachments = attachments ?? [],
        createdAt = createdAt ?? DateTime.now();
}
