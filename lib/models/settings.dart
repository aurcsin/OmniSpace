// File: lib/models/settings.dart

import 'package:hive/hive.dart';

part 'settings.g.dart';

/// User-configurable settings for the application.
@HiveType(typeId: 11)
class Settings extends HiveObject {
  @HiveField(0)
  bool darkMode;

  @HiveField(1)
  bool notificationsEnabled;

  @HiveField(2)
  String locale;

  @HiveField(3)
  String defaultTimeZone;

  Settings({
    this.darkMode = false,
    this.notificationsEnabled = true,
    this.locale = 'en_US',
    this.defaultTimeZone = 'UTC',
  });

  /// Convert Settings to JSON for persistence or synchronization.
  Map<String, dynamic> toJson() => {
        'darkMode': darkMode,
        'notificationsEnabled': notificationsEnabled,
        'locale': locale,
        'defaultTimeZone': defaultTimeZone,
      };

  /// Create Settings from a JSON map.
  factory Settings.fromJson(Map<String, dynamic> json) {
    return Settings(
      darkMode: json['darkMode'] as bool? ?? false,
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      locale: json['locale'] as String? ?? 'en_US',
      defaultTimeZone: json['defaultTimeZone'] as String? ?? 'UTC',
    );
  }
}
