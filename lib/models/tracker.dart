import 'package:hive/hive.dart';
import 'tracker_type.dart';

part 'tracker.g.dart';

@HiveType(typeId: 8)
class Tracker extends HiveObject {
  @HiveField(0) String id;
  @HiveField(1) TrackerType type;
  @HiveField(2) String title;
  @HiveField(3) double? progress;
  @HiveField(4) String? frequency;
  @HiveField(5) DateTime? start;
  @HiveField(6) List<String> childIds;
  @HiveField(7) bool isPinned;
  @HiveField(8) String tags;

  // NEW FIELDS
  @HiveField(9) bool isArchived;
  @HiveField(10) bool isTrashed;

  Tracker({
    required this.id,
    required this.type,
    this.title = '',
    this.progress,
    this.frequency,
    this.start,
    List<String>? childIds,
    this.isPinned = false,
    this.tags = '',
    this.isArchived = false,
    this.isTrashed = false,
  }) : childIds = childIds ?? [];
}
