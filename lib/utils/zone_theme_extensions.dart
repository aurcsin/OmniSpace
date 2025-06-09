// File: lib/utils/zone_theme_extensions.dart

import 'package:flutter/material.dart';
import 'package:omnispace/models/zone_theme.dart';

/// Convenience getters for [ZoneTheme].
extension ZoneThemeExtension on ZoneTheme {
  /// Human-friendly zone name.
  String get label {
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

  /// A representative color for the zone.
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
    }
  }
}
