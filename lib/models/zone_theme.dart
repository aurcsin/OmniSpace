// File: lib/models/zone_theme.dart

import 'package:hive/hive.dart';

part 'zone_theme.g.dart';

/// The six “zones” of your OmniSpace world.
@HiveType(typeId: 10)
enum ZoneTheme {
  @HiveField(0)
  Air,

  @HiveField(1)
  Earth,

  @HiveField(2)
  Fire,

  @HiveField(3)
  Water,

  @HiveField(4)
  Void,

  @HiveField(5)
  Fusion,
}
