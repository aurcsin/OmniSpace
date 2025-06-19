// File: lib/services/notification_service.dart

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

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

/// Handles scheduling and handling of local notifications for trackers.
class NotificationService {
  NotificationService._(this._client);
  static final NotificationService instance = NotificationService._(
    FlutterLocalNotificationsPlugin(),
  );

  final FlutterLocalNotificationsPlugin _client;

  /// Call once at app startup.
  Future<void> init() async {
    // Initialize TZ database
    await TimezoneHelperService.instance.init();

    // Request iOS/macOS permissions
    await _client
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    await _client
        .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    // Initialization settings
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

  void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null && payload.isNotEmpty) {
      final tracker = TrackerService.instance.byId(payload);
      if (tracker != null) {
        NavigatorService.instance.openTrackerEditor(tracker.id);
      }
    }
  }

  Future<void> scheduleForTracker(Tracker t) async {
    final id = t.id.hashCode;
    // Cancel any existing
    await _client.cancel(id);

    if (t.start == null) return;
    final tz.TZDateTime scheduled =
        tz.TZDateTime.from(t.start!, tz.local);

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        'omnispace_trackers',
        'Tracker Reminders',
        channelDescription: 'Reminders for your trackers',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker',
      ),
      iOS: const DarwinNotificationDetails(),
    );

    if (t.frequency == null || t.frequency!.isEmpty) {
      // One-shot
      await _client.zonedSchedule(
        id,
        t.title,
        'Tap to view details',
        scheduled,
        details,
        payload: t.id,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidAllowWhileIdle: true,
      );
    } else {
      final match = _mapFrequencyToComponent(t.frequency!);
      if (match == null) {
        throw NotificationException(
            'Unsupported frequency: ${t.frequency}');
      }
      await _client.zonedSchedule(
        id,
        t.title,
        'Recurring reminder',
        scheduled,
        details,
        payload: t.id,
        androidAllowWhileIdle: true,
        matchDateTimeComponents: match,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  Future<void> cancelForTracker(Tracker t) async {
    await _client.cancel(t.id.hashCode);
  }

  Future<void> rescheduleAll() async {
    await _client.cancelAll();
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
