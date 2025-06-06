// lib/models/omni_note.dart

import 'package:hive/hive.dart';

part 'omni_note.g.dart';

@HiveType(typeId: 0)
enum ZoneTheme {
  @HiveField(0)
  Air,   // “Sky”
  @HiveField(1)
  Earth, // “Garden”
  @HiveField(2)
  Fire,  // “Workshop”
  @HiveField(3)
  Water, // “Studio”
  @HiveField(4)
  Void,  // “Root Cave”
  @HiveField(5)
  Fusion // “Journal”
}

@HiveType(typeId: 1)
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
  String? recommendedTag;

  @HiveField(5)
  String tags; // comma-separated

  @HiveField(6)
  DateTime createdAt;

  OmniNote({
    required this.title,
    required this.subtitle,
    required this.content,
    required this.zone,
    this.recommendedTag,
    required this.tags,
    DateTime? createdAt,
  }) : this.createdAt = createdAt ?? DateTime.now();
}
