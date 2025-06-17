import 'package:hive/hive.dart';

part 'tracker_type.g.dart';

@HiveType(typeId: 14) // changed from 7 → 14
enum TrackerType {
  @HiveField(0)
  goal,

  @HiveField(1)
  task,

  @HiveField(2)
  event,

  @HiveField(3)
  series,
}
