import 'package:flutter/material.dart';
import '../models/zone_theme.dart';

extension ZoneThemeColor on ZoneTheme {
  /// Returns a distinct color for each zone.
  Color get color {
    switch (this) {
      case ZoneTheme.Air:
        return Colors.lightBlueAccent;
      case ZoneTheme.Earth:
        return Colors.brown;
      case ZoneTheme.Fire:
        return Colors.redAccent;
      case ZoneTheme.Water:
        return Colors.blueAccent;
      case ZoneTheme.Void:
        return Colors.grey;
      case ZoneTheme.Fusion:
        return Colors.purpleAccent;
    }
  }
}
