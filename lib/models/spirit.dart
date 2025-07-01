import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'zone_theme.dart';

part 'spirit.g.dart';

@HiveType(typeId: 50)
class Spirit extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String description;

  @HiveField(3)
  ZoneTheme realm;         // which elemental zone it belongs to

  @HiveField(4)
  bool isPrimary;          // the Master Spirit of the realm

  @HiveField(5)
  bool isNPC;              // static NPC guide vs collectible

  @HiveField(6)
  bool isCollectible;      // emergent life forms you can collect

  Spirit({
    required this.id,
    required this.name,
    required this.description,
    required this.realm,
    this.isPrimary = false,
    this.isNPC    = false,
    this.isCollectible = false,
  });
}
