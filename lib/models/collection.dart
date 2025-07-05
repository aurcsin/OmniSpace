// lib/models/collection.dart

import 'package:hive/hive.dart';

part 'collection.g.dart';

@HiveType(typeId: 20)
class Collection extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String ownerId;           // e.g. "self" or userId

  @HiveField(3)
  List<String> itemIds;     // IDs of any items (notes, trackers, etc.)

  @HiveField(4)
  String itemType;          // e.g. "note","tracker","project","spirit","artifact","loose"

  Collection({
    required this.id,
    required this.name,
    required this.ownerId,
    this.itemType = 'note',
    List<String>? itemIds,
  }) : itemIds = itemIds ?? [];
}
