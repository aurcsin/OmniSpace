import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() {
  test('Hive box stores value', () async {
    await Hive.initFlutter();
    final box = await Hive.openBox('helperTest');
    await box.put('foo', 'bar');
    expect(box.get('foo'), 'bar');
    await box.deleteFromDisk();
  });
}
