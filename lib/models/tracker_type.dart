import 'package:hive/hive.dart';

part 'tracker_type.g.dart';

/// Four tracker types supported by the app.
@HiveType(typeId: 4)
enum TrackerType {
  @HiveField(0)
  goal,
  @HiveField(1)
  event,
  @HiveField(2)
  routine,
  @HiveField(3)
  series,
}
