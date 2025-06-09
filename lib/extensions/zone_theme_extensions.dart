import 'package:flutter/material.dart';
import '../models/zone_theme.dart';

/// Extension to add UI helpers to [ZoneTheme].
extension ZoneThemeX on ZoneTheme {
  /// Human-readable name for display.
  String get displayName {
    switch (this) {
      case ZoneTheme.Air:
        return 'Air';
      case ZoneTheme.Earth:
        return 'Earth';
      case ZoneTheme.Fire:
        return 'Fire';
      case ZoneTheme.Water:
        return 'Water';
      case ZoneTheme.Void:
        return 'Void';
      case ZoneTheme.Fusion:
        return 'Fusion';
    }
  }

  /// Alias for [displayName] used in some widgets.
  String get label => displayName;

  /// Associated color for this zone.
  Color get color {
    switch (this) {
      case ZoneTheme.Air:
        return Colors.lightBlue;
      case ZoneTheme.Earth:
        return Colors.brown;
      case ZoneTheme.Fire:
        return Colors.red;
      case ZoneTheme.Water:
        return Colors.blueAccent;
      case ZoneTheme.Void:
        return Colors.grey;
      case ZoneTheme.Fusion:
        return Colors.purple;
      default:
        return Colors.black;
    }
  }
}
