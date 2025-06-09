// File: lib/models/tracker.dart

import 'package:hive/hive.dart';
import 'tracker_type.dart';

part 'tracker.g.dart';

@HiveType(typeId: 8)
class Tracker extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  TrackerType type;

  @HiveField(2)
  String title;

  /// For goal‐type trackers: completed fraction 0.0–1.0
  @HiveField(3)
  double? progress;

  /// For task‐type trackers: e.g. 'daily', 'weekly', etc.
  @HiveField(4)
  String? frequency;

  /// For event‐type trackers: when it happens
  @HiveField(5)
  DateTime? start;

  /// For series‐type trackers: list of child unit IDs
  @HiveField(6)
  List<String> childIds;

  Tracker({
    required this.id,
    required this.type,
    required this.title,
    this.progress,
    this.frequency,
    this.start,
    List<String>? childIds,
  }) : childIds = childIds ?? [];
}
