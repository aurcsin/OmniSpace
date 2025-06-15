// File: lib/services/user_profile_service.dart

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:omnispace/models/settings.dart';
import 'package:omnispace/models/user_profile.dart';

/// Service to load and save the user profile and settings via Hive.
class UserProfileService extends ChangeNotifier {
  UserProfileService._internal();
  static final UserProfileService instance = UserProfileService._internal();

  static const String _boxName = 'user_profile';
  late Box<UserProfile> _box;

  /// Initialize Hive box. Call once at app startup (main.dart).
  Future<void> init() async {
    // Register adapters if not already registered
    if (!Hive.isAdapterRegistered(UserProfileAdapter().typeId)) {
      Hive.registerAdapter(UserProfileAdapter());
    }
    if (!Hive.isAdapterRegistered(SettingsAdapter().typeId)) {
      Hive.registerAdapter(SettingsAdapter());
    }

    _box = await Hive.openBox<UserProfile>(_boxName);
    notifyListeners();
  }

  Future<void> _ensureInit() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await init();
    }
  }

  /// Fetch the stored profile, or return a default if none exists.
  Future<UserProfile> fetchProfile() async {
    await _ensureInit();
    if (_box.isEmpty) {
      final profile = UserProfile();
      await _box.put('profile', profile);
      return profile;
    }
    return _box.get('profile')!;
  }

  /// Update only the settings portion of the profile.
  Future<void> updateSettings(Settings settings) async {
    await _ensureInit();
    UserProfile profile;
    if (_box.isEmpty) {
      profile = UserProfile(settings: settings);
    } else {
      profile = _box.get('profile')!;
      profile.settings = settings;
    }
    await _box.put('profile', profile);
    notifyListeners();
  }

  /// Current in-memory profile, or null if not loaded.
  UserProfile? get currentProfile {
    if (Hive.isBoxOpen(_boxName) && _box.isNotEmpty) {
      return _box.get('profile');
    }
    return null;
  }

  /// Delete the stored profile (resets to defaults).
  Future<void> clearProfile() async {
    await _ensureInit();
    await _box.clear();
    notifyListeners();
  }
}
