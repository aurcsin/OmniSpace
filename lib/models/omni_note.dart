import 'package:hive/hive.dart';

part 'omni_note.g.dart';

@HiveType(typeId: 1)
class OmniNote extends HiveObject {
  @HiveField(0)
  int? id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String subtitle;

  @HiveField(3)
  String content;

  @HiveField(4)
  String? tags;

  @HiveField(5)
  DateTime createdAt;

  @HiveField(6)
  String zoneTheme;

  @HiveField(7)
  bool isPinned;

  @HiveField(8)
  List<String> mediaPaths;

  OmniNote({
    this.id,
    required this.title,
    required this.subtitle,
    required this.content,
    this.tags,
    required this.createdAt,
    required this.zoneTheme,
    this.isPinned = false,
    List<String>? mediaPaths,
  }) : mediaPaths = mediaPaths ?? [];
}
