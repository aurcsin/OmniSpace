// File: lib/models/event.dart

import 'package:hive/hive.dart';

part 'event.g.dart';

/// A calendar event attached to a note.
@HiveType(typeId: 5)
class Event extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  DateTime start;

  @HiveField(3)
  DateTime? end;

  Event({
    required this.id,
    this.title = '',
    required this.start,
    this.end,
  });

  /// Convert to JSON for sync or serialization.
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'start': start.toIso8601String(),
        'end': end?.toIso8601String(),
      };

  /// Create an Event from a JSON map.
  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] as String,
      title: json['title'] as String,
      start: DateTime.parse(json['start'] as String),
      end: json['end'] != null
          ? DateTime.parse(json['end'] as String)
          : null,
    );
  }
}
