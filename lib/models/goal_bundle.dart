import 'package:hive/hive.dart';
import 'goal.dart';

part 'goal_bundle.g.dart';

@HiveType(typeId: 14)
class GoalBundle extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  List<Goal> goals;

  GoalBundle({required this.id, required this.name, List<Goal>? goals})
      : goals = goals ?? [];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'goals': goals.map((g) => g.toJson()).toList(),
      };

  factory GoalBundle.fromJson(Map<String, dynamic> json) => GoalBundle(
        id: json['id'] as String,
        name: json['name'] as String,
        goals: (json['goals'] as List<dynamic>? ?? [])
            .map((e) => Goal.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
