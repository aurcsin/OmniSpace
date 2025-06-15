import 'package:flutter/material.dart';

import '../models/omni_note.dart';

extension ZoneThemeColor on ZoneTheme {
  /// Primary color associated with each zone theme.
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
