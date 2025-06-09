// File: lib/services/timezone_helper_service.dart

import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'package:intl/intl.dart';

/// A helper service for working with time zones and formatting dates/times.
class TimezoneHelperService {
  // Singleton instance
  static final TimezoneHelperService instance = TimezoneHelperService._internal();
  TimezoneHelperService._internal() {
    _initialize();
  }

  bool _initialized = false;
  late tz.Location _defaultLocation;

  /// Initialize the time zone database and default location. Called once internally.
  void _initialize() {
    if (_initialized) return;
    tzdata.initializeTimeZones();
    // Set default to the system local timezone
    _defaultLocation = tz.local;
    _initialized = true;
  }

  /// Manually set default time zone by IANA name, e.g. 'America/Phoenix'.
  /// Throws if the name is invalid.
  void setDefaultLocation(String timeZoneName) {
    _initialize();
    _defaultLocation = tz.getLocation(timeZoneName);
  }

  /// Get the current time in the default time zone.
  tz.TZDateTime now() {
    _initialize();
    return tz.TZDateTime.now(_defaultLocation);
  }

  /// Convert a [dateTime] to a specific time zone.
  tz.TZDateTime convertToZone(DateTime dateTime, String timeZoneName) {
    _initialize();
    final loc = tz.getLocation(timeZoneName);
    return tz.TZDateTime.from(dateTime, loc);
  }

  /// Format a [dateTime] in the given time zone using [pattern], defaults to default zone.
  String format(
    DateTime dateTime, {
    String pattern = 'y-MM-dd HH:mm',
    String? timeZone,
    bool isUtc = false,
  }) {
    _initialize();
    tz.TZDateTime dt;
    if (timeZone != null) {
      dt = tz.TZDateTime.from(dateTime, tz.getLocation(timeZone));
    } else if (isUtc) {
      dt = tz.TZDateTime.from(dateTime.toUtc(), tz.UTC);
    } else {
      dt = tz.TZDateTime.from(dateTime, _defaultLocation);
    }
    return DateFormat(pattern).format(dt);
  }

  /// List available IANA time zone names (sorted).
  List<String> get availableTimeZones {
    _initialize();
    final zones = tz.timeZoneDatabase.locations.keys.toList();
    zones.sort();
    return zones;
  }
}
