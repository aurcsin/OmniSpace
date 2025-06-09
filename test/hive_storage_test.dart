import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() {
  test('Hive opens and retrieves data', () async {
    await Hive.initFlutter();
    final box = await Hive.openBox('storageTest');
    await box.put('a', 1);
    expect(box.get('a'), 1);
    await box.deleteFromDisk();
  });
}
