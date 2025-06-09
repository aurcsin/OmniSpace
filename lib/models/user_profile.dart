// File: lib/models/user_profile.dart

import 'package:hive/hive.dart';
import 'settings.dart';

part 'user_profile.g.dart';

/// Represents a user's profile, including personal details and settings.
@HiveType(typeId: 12)
class UserProfile extends HiveObject {
  @HiveField(0)
  String? userId;

  @HiveField(1)
  String? name;

  @HiveField(2)
  String? email;

  @HiveField(3)
  Settings settings;

  UserProfile({
    this.userId,
    this.name,
    this.email,
    Settings? settings,
  }) : settings = settings ?? Settings();
}
