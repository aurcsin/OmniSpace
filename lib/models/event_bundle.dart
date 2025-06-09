import 'package:hive/hive.dart';
import 'event.dart';

part 'event_bundle.g.dart';

@HiveType(typeId: 15)
class EventBundle extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  List<Event> events;

  EventBundle({required this.id, required this.name, List<Event>? events})
      : events = events ?? [];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'events': events.map((e) => e.toJson()).toList(),
      };

  factory EventBundle.fromJson(Map<String, dynamic> json) => EventBundle(
        id: json['id'] as String,
        name: json['name'] as String,
        events: (json['events'] as List<dynamic>? ?? [])
            .map((e) => Event.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
