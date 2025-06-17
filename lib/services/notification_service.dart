// File: lib/services/notification_service.dart

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../models/tracker.dart';
import 'navigator_service.dart';
// ← point at your existing helper file
import 'timezone_helper.dart';
import 'tracker_service.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // Ensure the IANA time zone database is initialized
    TimezoneHelperService.instance;

    // Android initialization
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    // iOS initialization
    const iosInit = DarwinInitializationSettings();

    await _plugin.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
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
    // Cancel any existing notification for this tracker
    await _plugin.cancel(t.id.hashCode);

    // Only schedule if there's a start date
    if (t.start == null) return;

    // Convert to TZ-aware time
    final tz.TZDateTime scheduled = tz.TZDateTime.from(t.start!, tz.local);

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        'omnispace_trackers',
        'Tracker Reminders',
        channelDescription: 'Reminders for your goals, tasks, events',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    if (t.frequency == null) {
      // One-off reminder
      await _plugin.zonedSchedule(
        t.id.hashCode,
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
      // Recurring reminder
      final matchComponent = _mapFrequencyToComponent(t.frequency!);
      await _plugin.zonedSchedule(
        t.id.hashCode,
        t.title,
        'Recurring reminder',
        scheduled,
        details,
        payload: t.id,
        androidAllowWhileIdle: true,
        matchDateTimeComponents: matchComponent,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  Future<void> cancelForTracker(Tracker t) async {
    await _plugin.cancel(t.id.hashCode);
  }

  Future<void> rescheduleAll(List<Tracker> all) async {
    await _plugin.cancelAll();
    for (final t in all) {
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
