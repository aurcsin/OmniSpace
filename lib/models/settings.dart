// File: lib/models/settings.dart

import 'package:hive/hive.dart';

part 'settings.g.dart';

/// User-configurable settings for the application.
@HiveType(typeId: 14)
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
}
