// File: lib/models/tracker_collection.dart

import 'package:hive/hive.dart';

part 'tracker_collection.g.dart';

/// A named group of Trackers.
@HiveType(typeId: 15)
class TrackerCollection extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String ownerId;

  @HiveField(3)
  List<String> trackerIds;

  TrackerCollection({
    required this.id,
    required this.name,
    required this.ownerId,
    List<String>? trackerIds,
  }) : trackerIds = trackerIds ?? [];
}
