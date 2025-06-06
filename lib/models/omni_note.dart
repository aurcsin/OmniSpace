// lib/models/omni_note.dart

import 'package:hive/hive.dart';
import 'attachment.dart';

part 'omni_note.g.dart';

@HiveType(typeId: 0)
enum ZoneTheme {
  @HiveField(0)
  Air,   // Sky
  @HiveField(1)
  Earth, // Garden
  @HiveField(2)
  Fire,  // Workshop
  @HiveField(3)
  Water, // Studio
  @HiveField(4)
  Void,  // Root Cave
  @HiveField(5)
  Fusion // Journal
}

@HiveType(typeId: 1)
class OmniNote extends HiveObject {
  @HiveField(0)
  int? id; // Assigned by Hive when you add the note to a box

  @HiveField(1)
  String title;

  @HiveField(2)
  String subtitle;

  @HiveField(3)
  String content;

  @HiveField(4)
  ZoneTheme zone;

  @HiveField(5)
  String? recommendedTag;

  @HiveField(6)
  String tags; // comma-separated

  @HiveField(7)
  DateTime createdAt;

  /// NEW: Zero or more media attachments (images, audio, video).
  @HiveField(8)
  List<Attachment> attachments;

  OmniNote({
    this.id,
    required this.title,
    required this.subtitle,
    required this.content,
    required this.zone,
    this.recommendedTag,
    required this.tags,
    DateTime? createdAt,
    List<Attachment>? attachments,
  })  : this.createdAt = createdAt ?? DateTime.now(),
        this.attachments = attachments ?? [];
}
