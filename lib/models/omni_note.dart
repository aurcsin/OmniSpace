// lib/models/omni_note.dart

import 'package:hive/hive.dart';
import 'attachment.dart';

part 'omni_note.g.dart';

@HiveType(typeId: 3)
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
  String tags; // comma-separated

  @HiveField(5)
  int colorValue;

  @HiveField(6)
  String? mood;

  @HiveField(7)
  String? direction;

  @HiveField(8)
  String? projectId;

  @HiveField(9)
  DateTime createdAt;

  @HiveField(10)
  List<Attachment> attachments;

  @HiveField(11)
  String? recommendedTag;

  OmniNote({
    required this.title,
    this.subtitle = '',
    this.content = '',
    this.zone = ZoneTheme.Fusion,
    this.tags = '',
    this.colorValue = 0xFFFFFFFF,
    this.mood,
    this.direction,
    this.projectId,
    DateTime? createdAt,
    List<Attachment>? attachments,
    this.recommendedTag,
  })  : createdAt = createdAt ?? DateTime.now(),
        attachments = attachments ?? <Attachment>[];
}
