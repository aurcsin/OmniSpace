// File: lib/services/notification_service.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:hive/hive.dart';

import '../models/tracker.dart';
import 'navigator_service.dart';
import 'timezone_helper_service.dart';
import 'tracker_service.dart';

/// Exception for notification errors.
class NotificationException implements Exception {
  final String message;
  NotificationException(this.message);
  @override
  String toString() => 'NotificationException: $message';
}

/// Handles scheduling and handling of local notifications for trackers,
/// and persists the “enabled” setting in Hive.
class NotificationService {
  NotificationService._(this._client);
  static final NotificationService instance =
      NotificationService._(FlutterLocalNotificationsPlugin());

  final FlutterLocalNotificationsPlugin _client;

  late final Box _settingsBox;
  static const _settingsBoxName = 'settings';
  static const _enabledKey = 'notificationsEnabled';

  /// Call once at app startup.
  Future<void> init() async {
    _settingsBox = await Hive.openBox(_settingsBoxName);
    TimezoneHelperService.instance;

    if (!kIsWeb) {
      await _client
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      await _client
          .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);

      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const darwinSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      await _client.initialize(
        const InitializationSettings(
          android: androidSettings,
          iOS: darwinSettings,
          macOS: darwinSettings,
        ),
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );
    }

    // Ensure trackers are loaded before scheduling
    await TrackerService.instance.init();

    if (await getEnabled()) {
      await rescheduleAll();
    }
  }

  /// Returns whether reminders are enabled.
  Future<bool> getEnabled() async {
    return _settingsBox.get(_enabledKey, defaultValue: true) as bool;
  }

  /// Toggle reminders on/off.
  Future<void> setEnabled(bool enabled) async {
    await _settingsBox.put(_enabledKey, enabled);
    if (enabled) {
      await rescheduleAll();
    } else if (!kIsWeb) {
      await _client.cancelAll();
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null && payload.isNotEmpty) {
      // Use getById instead of byId
      final tracker = TrackerService.instance.getById(payload);
      if (tracker != null) {
        NavigatorService.instance.openTrackerEditor(tracker.id);
      }
    }
  }

  Future<void> scheduleForTracker(Tracker t) async {
    if (kIsWeb) return;
    final id = t.id.hashCode;
    await _client.cancel(id);
    if (t.start == null) return;

    final scheduled = tz.TZDateTime.from(t.start!, tz.local);
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        'omnispace_trackers',
        'Tracker Reminders',
        channelDescription: 'Reminders for your trackers',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'tracker_ticker',
      ),
      iOS: const DarwinNotificationDetails(),
    );

    if (t.frequency == null || t.frequency!.isEmpty) {
      await _client.zonedSchedule(
        id,
        t.title,
        'Tap to view details',
        scheduled,
        details,
        payload: t.id,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } else {
      final match = _mapFrequencyToComponent(t.frequency!);
      if (match == null) {
        throw NotificationException('Unsupported frequency: ${t.frequency}');
      }
      await _client.zonedSchedule(
        id,
        t.title,
        'Recurring reminder',
        scheduled,
        details,
        payload: t.id,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: match,
      );
    }
  }

  Future<void> cancelForTracker(Tracker t) async {
    if (kIsWeb) return;
    await _client.cancel(t.id.hashCode);
  }

  Future<void> rescheduleAll() async {
    if (!kIsWeb) {
      await _client.cancelAll();
    }
    for (final t in TrackerService.instance.all) {
      await scheduleForTracker(t);
    }
  }

  DateTimeComponents? _mapFrequencyToComponent(String freq) {
    switch (freq.toLowerCase()) {
      case 'daily':
        return DateTimeComponents.time;
      case 'weekly':
        return DateTimeComponents.dayOfWeekAndTime;
      case 'monthly':
        return DateTimeComponents.dayOfMonthAndTime;
      case 'yearly':
        return DateTimeComponents.dateAndTime;
      default:
        return null;
    }
  }
}
