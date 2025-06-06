import 'package:hive/hive.dart';

part 'omni_note.g.dart';

@HiveType(typeId: 0)
class OmniNote extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String subtitle;

  @HiveField(2)
  String content;

  @HiveField(3)
  String tags;

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  String zoneTheme;

  @HiveField(6)
  DateTime lastUpdated;

  OmniNote({
    required this.title,
    required this.subtitle,
    required this.content,
    required this.tags,
    required this.createdAt,
    required this.zoneTheme,
    required this.lastUpdated,
  });
}
