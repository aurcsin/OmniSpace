import 'package:hive/hive.dart';

part 'project.g.dart';

@HiveType(typeId: 8)
class Project extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  List<String> noteIds;

  @HiveField(3)
  List<String> trackerIds;

  @HiveField(4)
  List<String> goalIds;

  @HiveField(5)
  List<String> eventIds;

  @HiveField(6)
  List<String> seriesIds;

  @HiveField(7)
  String tags;

  Project({
    required this.id,
    this.title = '',
    List<String>? noteIds,
    List<String>? trackerIds,
    List<String>? goalIds,
    List<String>? eventIds,
    List<String>? seriesIds,
    this.tags = '',
  })  : noteIds = noteIds ?? [],
        trackerIds = trackerIds ?? [],
        goalIds = goalIds ?? [],
        eventIds = eventIds ?? [],
        seriesIds = seriesIds ?? [];
}
