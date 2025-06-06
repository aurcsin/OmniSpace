import 'package:hive/hive.dart';

part 'day_reflection.g.dart';

@HiveType(typeId: 2)
class DayReflection extends HiveObject {
  @HiveField(0)
  String dateKey; // Format: yyyy-MM-dd

  @HiveField(1)
  String summary;

  @HiveField(2)
  List<int> noteIds;

  DayReflection({
    required this.dateKey,
    this.summary = '',
    List<int>? noteIds,
  }) : noteIds = noteIds ?? [];
}
