// File: lib/models/zone_theme.dart

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

part 'zone_theme.g.dart';

/// The six “zones” of your OmniSpace world.
@HiveType(typeId: 19)
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

extension ZoneThemeExtension on ZoneTheme {
  /// Human-readable name, e.g. "Air", "Earth", "Fusion", etc.
  String get displayName => describeEnum(this);

  /// Default icon for this realm.
  IconData get icon {
    switch (this) {
      case ZoneTheme.Air:
        return Icons.cloud;
      case ZoneTheme.Earth:
        return Icons.grass;
      case ZoneTheme.Fire:
        return Icons.local_fire_department;
      case ZoneTheme.Water:
        return Icons.water;
      case ZoneTheme.Void:
        return Icons.remove; // or Icons.night_shelter
      case ZoneTheme.Fusion:
        return Icons.bubble_chart;
    }
  }
}
