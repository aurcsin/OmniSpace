// File: lib/models/tracker_collection.dart

import 'package:hive/hive.dart';

part 'tracker_collection.g.dart';

@HiveType(typeId: 14)
class TrackerCollection extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  List<String> trackerIds;

  TrackerCollection({
    required this.id,
    required this.name,
    this.trackerIds = const [],
  });
}
