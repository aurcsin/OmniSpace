// File: lib/models/tracker_type.dart

import 'package:hive/hive.dart';

part 'tracker_type.g.dart';

@HiveType(typeId: 7)
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
