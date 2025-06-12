// File: lib/themes/theme_loader.dart

import 'package:flutter/material.dart';

/// Loads a named theme. In a real implementation, themes could be provided by
/// plugins or downloaded. Here we just switch between a couple of presets.
class ThemeLoader {
  static ThemeData load(String name) {
    switch (name) {
      case 'dark':
        return ThemeData.dark().copyWith(primaryColor: Colors.deepPurple);
      case 'light':
        return ThemeData.light().copyWith(primaryColor: Colors.deepPurple);
      default:
        return ThemeData.fallback();
    }
  }
}
