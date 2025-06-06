import 'package:hive/hive.dart';
import 'attachment.dart';
import 'task.dart';
import 'goal.dart';
import 'event.dart';

part 'omni_note.g.dart';

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
  String tags;

  @HiveField(6)
  DateTime createdAt;

  @HiveField(7)
  List<Attachment> attachments;

  /// Tasks attached to this note (or null if none)
  @HiveField(8)
  List<Task>? tasks;

  /// Goals attached to this note (or null)
  @HiveField(9)
  List<Goal>? goals;

  /// Events attached to this note (or null)
  @HiveField(10)
  List<Event>? events;

  @HiveField(11)
  String? mood;

  @HiveField(12)
  String? direction;

  @HiveField(13)
  String? projectId;

  @HiveField(14)
  int colorValue;

  @HiveField(15)
  bool starred;

  @HiveField(16)
  bool pinned;

  @HiveField(17)
  bool archived;

  @HiveField(18)
  bool isPrivate;

  OmniNote({
    required this.title,
    required this.subtitle,
    required this.content,
    required this.zone,
    this.recommendedTag,
    required this.tags,
    DateTime? createdAt,
    List<Attachment>? attachments,
    this.tasks,
    this.goals,
    this.events,
    this.mood,
    this.direction,
    this.projectId,
    int? colorValue,
    bool? starred,
    bool? pinned,
    bool? archived,
    bool? isPrivate,
  })  : this.createdAt = createdAt ?? DateTime.now(),
        this.attachments = attachments ?? [],
        this.colorValue = colorValue ?? 0xFFFFFFFF,
        this.starred = starred ?? false,
        this.pinned = pinned ?? false,
        this.archived = archived ?? false,
        this.isPrivate = isPrivate ?? false;
}

@HiveType(typeId: 0)
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
