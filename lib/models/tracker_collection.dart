// File: lib/models/tracker_collection.dart

import 'package:hive/hive.dart';

part 'tracker_collection.g.dart';

// Use a unique type ID distinct from other models
@HiveType(typeId: 22)
class TrackerCollection extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  /// Optional owner ID if this collection is scoped beneath a parent
  @HiveField(2)
  String ownerId;

  /// Member tracker IDs contained in this collection
  @HiveField(3)
  List<String> trackerIds;

  TrackerCollection({
    required this.id,
    required this.name,
    required this.ownerId,
    this.trackerIds = const [],
  });
}
