// File: lib/models/spirit.dart

import 'package:hive/hive.dart';
import 'zone_theme.dart';

part 'spirit.g.dart';

/// A creature of an Elemental Realm.
@HiveType(typeId: 12)
class Spirit extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String mythos;

  @HiveField(3)
  final String purpose;

  @HiveField(4)
  final String useInApp;

  @HiveField(5)
  final ZoneTheme realm;

  @HiveField(6)
  final bool isPrimary;

  @HiveField(7)
  final bool isNPC;

  @HiveField(8)
  final bool isCollectible;

  @HiveField(9)
  final String archetype;

  @HiveField(10)
  final int xpValue;

  Spirit({
    required this.id,
    required this.name,
    required this.mythos,
    required this.purpose,
    required this.useInApp,
    required this.realm,
    this.isPrimary = false,
    this.isNPC = false,
    this.isCollectible = true,
    required this.archetype,
    required this.xpValue,
  });
}
