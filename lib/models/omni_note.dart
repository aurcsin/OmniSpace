// lib/models/omni_note.dart

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import 'attachment.dart';
import 'task.dart';
import 'goal.dart';
import 'event.dart';
import 'zone_theme.dart';

part 'omni_note.g.dart';

/// Your core note model with extended link and lock fields.
@HiveType(typeId: 7)
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
  ZoneTheme? zone;

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
  bool isStarred;

  @HiveField(20)
  bool isArchived;

  @HiveField(21)
  bool isTrashed;

  @HiveField(22)
  bool isLocked;

  @HiveField(23)
  String? lockPassword;

  @HiveField(24)
  String? linkedSpiritId;

  @HiveField(25)
  String? linkedTrackerId;

  @HiveField(26)
  String? linkedCollectionId;

  OmniNote({
    required this.id,
    this.title = '',
    this.subtitle = '',
    this.content = '',
    this.zone,
    this.tags = '',
    this.colorValue = 0xFFFFFFFF,
    this.mood,
    this.direction,
    this.projectId,
    this.recommendedTag,
    this.seriesId,
    this.linkedSpiritId,
    this.linkedTrackerId,
    this.linkedCollectionId,
    List<Attachment>? attachments,
    this.tasks,
    this.goals,
    this.events,
    DateTime? createdAt,
    DateTime? lastUpdated,
    this.isPinned = false,
    this.isStarred = false,
    this.isArchived = false,
    this.isTrashed = false,
    this.isLocked = false,
    this.lockPassword,
  })  : attachments   = attachments ?? [],
        createdAt     = createdAt ?? DateTime.now(),
        lastUpdated   = lastUpdated ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'content': content,
      'zone': zone != null ? describeEnum(zone!) : null,
      'tags': tags,
      'colorValue': colorValue,
      'mood': mood,
      'direction': direction,
      'projectId': projectId,
      'recommendedTag': recommendedTag,
      'seriesId': seriesId,
      'linkedSpiritId': linkedSpiritId,
      'linkedTrackerId': linkedTrackerId,
      'linkedCollectionId': linkedCollectionId,
      'attachments': attachments.map((a) => a.toJson()).toList(),
      'tasks': tasks?.map((t) => t.toJson()).toList(),
      'goals': goals?.map((g) => g.toJson()).toList(),
      'events': events?.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'lastUpdated': lastUpdated.toIso8601String(),
      'isPinned': isPinned,
      'isStarred': isStarred,
      'isArchived': isArchived,
      'isTrashed': isTrashed,
      'isLocked': isLocked,
      'lockPassword': lockPassword,
    };
  }

  factory OmniNote.fromJson(Map<String, dynamic> json) {
    return OmniNote(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      content: json['content'] as String? ?? '',
      zone: json['zone'] != null
          ? ZoneTheme.values.firstWhere((z) => describeEnum(z) == json['zone'])
          : null,
      tags: json['tags'] as String? ?? '',
      colorValue: json['colorValue'] as int? ?? 0xFFFFFFFF,
      mood: json['mood'] as String?,
      direction: json['direction'] as String?,
      projectId: json['projectId'] as String?,
      recommendedTag: json['recommendedTag'] as String?,
      seriesId: json['seriesId'] as String?,
      linkedSpiritId: json['linkedSpiritId'] as String?,
      linkedTrackerId: json['linkedTrackerId'] as String?,
      linkedCollectionId: json['linkedCollectionId'] as String?,
      attachments: (json['attachments'] as List<dynamic>?)
          ?.map((a) => Attachment.fromJson(a as Map<String, dynamic>))
          .toList() ?? [],
      tasks: (json['tasks'] as List<dynamic>?)
          ?.map((t) => Task.fromJson(t as Map<String, dynamic>))
          .toList(),
      goals: (json['goals'] as List<dynamic>?)
          ?.map((g) => Goal.fromJson(g as Map<String, dynamic>))
          .toList(),
      events: (json['events'] as List<dynamic>?)
          ?.map((e) => Event.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'] as String)
          : DateTime.now(),
      isPinned: json['isPinned'] as bool? ?? false,
      isStarred: json['isStarred'] as bool? ?? false,
      isArchived: json['isArchived'] as bool? ?? false,
      isTrashed: json['isTrashed'] as bool? ?? false,
      isLocked: json['isLocked'] as bool? ?? false,
      lockPassword: json['lockPassword'] as String?,
    );
  }
}
