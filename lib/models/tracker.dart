import 'package:hive/hive.dart';
import 'tracker_type.dart';

part 'tracker.g.dart';

@HiveType(typeId: 3)
class Tracker extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  TrackerType type;

  @HiveField(2)
  String title;

  @HiveField(3)
  double? progress;       // for goals

  @HiveField(4)
  String? frequency;      // for routines

  @HiveField(5)
  DateTime? start;        // for events

  @HiveField(6)
  String tags;            // linked note IDs

  @HiveField(7)
  bool isCompleted;

  @HiveField(8)
  bool isTrashed;

  @HiveField(9)
  List<String> childIds;         // nested subgoals/subevents

  @HiveField(10)
  List<String> linkedTrackerIds; // cross-links

  @HiveField(11)
  List<String> linkedNoteIds;

  Tracker({
    required this.id,
    required this.type,
    this.title = '',
    this.progress,
    this.frequency,
    this.start,
    this.tags = '',
    this.isCompleted = false,
    this.isTrashed = false,
    List<String>? childIds,
    List<String>? linkedTrackerIds,
    List<String>? linkedNoteIds,
  })  : childIds = childIds ?? [],
        linkedTrackerIds = linkedTrackerIds ?? [],
        linkedNoteIds = linkedNoteIds ?? [];

  void toggleComplete() {
    isCompleted = !isCompleted;
    save();
  }
}
