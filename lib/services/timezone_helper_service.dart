// File: lib/services/timezone_helper_service.dart

import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'package:intl/intl.dart';

/// A helper service for working with time zones and formatting dates/times.
class TimezoneHelperService {
  TimezoneHelperService._internal();
  static final TimezoneHelperService instance = TimezoneHelperService._internal();

  bool _initialized = false;
  late tz.Location _defaultLocation;

  /// Initialize the time zone database and default location. Call this once at startup.
  Future<void> init() async {
    if (_initialized) return;
    // Load the time zone database
    tzdata.initializeTimeZones();
    try {
      final String localName = await FlutterNativeTimezone.getLocalTimezone();
      _defaultLocation = tz.getLocation(localName);
      tz.setLocalLocation(_defaultLocation);
    } catch (_) {
      // Fallback to UTC
      _defaultLocation = tz.UTC;
      tz.setLocalLocation(tz.UTC);
    }
    _initialized = true;
  }

  /// Manually set default time zone by IANA name, e.g. 'America/Phoenix'.
  /// Throws an error if the name is invalid.
  void setDefaultLocation(String timeZoneName) {
    if (!_initialized) {
      throw StateError('TimezoneHelperService not initialized');
    }
    _defaultLocation = tz.getLocation(timeZoneName);
    tz.setLocalLocation(_defaultLocation);
  }

  /// Get the current time in the default time zone.
  tz.TZDateTime now() {
    if (!_initialized) {
      throw StateError('TimezoneHelperService not initialized');
    }
    return tz.TZDateTime.now(_defaultLocation);
  }

  /// Convert a [dateTime] to a specific time zone.
  tz.TZDateTime convertToZone(DateTime dateTime, String timeZoneName) {
    if (!_initialized) {
      throw StateError('TimezoneHelperService not initialized');
    }
    final loc = tz.getLocation(timeZoneName);
    return tz.TZDateTime.from(dateTime, loc);
  }

  /// Format a [dateTime] in the given time zone using [pattern].
  /// Defaults to default zone, or UTC if [isUtc] is true.
  String format(
    DateTime dateTime, {
    String pattern = 'y-MM-dd HH:mm',
    String? timeZone,
    bool isUtc = false,
  }) {
    if (!_initialized) {
      throw StateError('TimezoneHelperService not initialized');
    }
    tz.TZDateTime dt;
    if (timeZone != null) {
      final loc = tz.getLocation(timeZone);
      dt = tz.TZDateTime.from(dateTime, loc);
    } else if (isUtc) {
      dt = tz.TZDateTime.from(dateTime.toUtc(), tz.UTC);
    } else {
      dt = tz.TZDateTime.from(dateTime, _defaultLocation);
    }
    return DateFormat(pattern).format(dt);
  }

  /// List available IANA time zone names (sorted alphabetically).
  List<String> get availableTimeZones {
    if (!_initialized) {
      throw StateError('TimezoneHelperService not initialized');
    }
    final zones = tz.timeZoneDatabase.locations.keys.toList();
    zones.sort();
    return zones;
  }
}
