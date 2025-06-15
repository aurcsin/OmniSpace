import 'package:flutter_test/flutter_test.dart';
import 'package:omnispace/services/timezone_helper.dart';

void main() {
  final tzHelper = TimezoneHelperService.instance;

  test('setDefaultLocation changes now() time zone', () {
    final before = tzHelper.now();
    tzHelper.setDefaultLocation('UTC');
    final after = tzHelper.now();
    expect(after.location, isNot(before.location));
    expect(after.location.name, 'UTC');
  });

  test('convertToZone converts correctly', () {
    final dt = DateTime.utc(2023, 1, 1, 12);
    final converted = tzHelper.convertToZone(dt, 'America/New_York');
    expect(converted.timeZoneName, anyOf('EST', 'EDT'));
  });

  test('format returns expected string', () {
    final dt = DateTime.utc(2023, 1, 1, 12, 30);
    final formatted = tzHelper.format(dt, pattern: 'y-MM-dd HH:mm', timeZone: 'UTC');
    expect(formatted, '2023-01-01 12:30');
  });
}
