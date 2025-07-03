import 'package:hive/hive.dart';

part 'tracker_type.g.dart';

@HiveType(typeId: 16) // choose an unused typeId
enum TrackerType {
  @HiveField(0)
  goal,

  @HiveField(1)
  task,    // ← added back

  @HiveField(2)
  event,

  @HiveField(3)
  routine,

  @HiveField(4)
  series,
}
