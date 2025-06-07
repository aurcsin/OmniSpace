import 'package:hive/hive.dart';

part 'goal.g.dart';

@HiveType(typeId: 5)
class Goal extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String? description;

  /// A growing list of “progress notes” (e.g. ["Did X today", "Followed up with Y", …])
  @HiveField(2)
  List<String> progressNotes;

  Goal({
    required this.title,
    this.description,
    List<String>? progressNotes,
  }) : progressNotes = progressNotes ?? [];
}
