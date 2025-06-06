import 'package:hive/hive.dart';

part 'event.g.dart';

@HiveType(typeId: 6)
class Event extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  DateTime eventDate;

  @HiveField(2)
  bool isRecurring;

  /// If `isRecurring == true`, this might be "DAILY", "WEEKLY", "MONTHLY", etc.
  @HiveField(3)
  String? recurringRule;

  Event({
    required this.title,
    required this.eventDate,
    this.isRecurring = false,
    this.recurringRule,
  });
}
