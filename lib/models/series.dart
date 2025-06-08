import 'package:hive/hive.dart';

part 'series.g.dart';

@HiveType(typeId: 8)
class Series extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  Series({required this.id, required this.name});
}
