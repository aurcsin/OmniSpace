import 'package:hive/hive.dart';
import 'goal_bundle.dart';
import 'event_bundle.dart';
import 'task_bundle.dart';

part 'series_bundle.g.dart';

@HiveType(typeId: 16)
class SeriesBundle extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  List<GoalBundle> goalBundles;

  @HiveField(3)
  List<EventBundle> eventBundles;

  @HiveField(4)
  List<TaskBundle> taskBundles;

  @HiveField(5)
  List<SeriesBundle> seriesBundles;

  SeriesBundle({
    required this.id,
    required this.name,
    List<GoalBundle>? goalBundles,
    List<EventBundle>? eventBundles,
    List<TaskBundle>? taskBundles,
    List<SeriesBundle>? seriesBundles,
  })  : goalBundles = goalBundles ?? [],
        eventBundles = eventBundles ?? [],
        taskBundles = taskBundles ?? [],
        seriesBundles = seriesBundles ?? [];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'goalBundles': goalBundles.map((g) => g.toJson()).toList(),
        'eventBundles': eventBundles.map((e) => e.toJson()).toList(),
        'taskBundles': taskBundles.map((t) => t.toJson()).toList(),
        'seriesBundles': seriesBundles.map((s) => s.toJson()).toList(),
      };

  factory SeriesBundle.fromJson(Map<String, dynamic> json) => SeriesBundle(
        id: json['id'] as String,
        name: json['name'] as String,
        goalBundles: (json['goalBundles'] as List<dynamic>? ?? [])
            .map((e) => GoalBundle.fromJson(e as Map<String, dynamic>))
            .toList(),
        eventBundles: (json['eventBundles'] as List<dynamic>? ?? [])
            .map((e) => EventBundle.fromJson(e as Map<String, dynamic>))
            .toList(),
        taskBundles: (json['taskBundles'] as List<dynamic>? ?? [])
            .map((e) => TaskBundle.fromJson(e as Map<String, dynamic>))
            .toList(),
        seriesBundles: (json['seriesBundles'] as List<dynamic>? ?? [])
            .map((e) => SeriesBundle.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
