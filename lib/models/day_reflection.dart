import 'package:hive/hive.dart';

part 'day_reflection.g.dart';

@HiveType(typeId: 6) // changed from 3 → 6
class DayReflection extends HiveObject {
  @HiveField(0)
  String dateKey;

  @HiveField(1)
  String? summary;

  DayReflection({required this.dateKey, this.summary});
}
