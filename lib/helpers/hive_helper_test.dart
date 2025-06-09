import 'dart:io';
import 'package:hive/hive.dart';
import 'package:test/test.dart';

void main() {
  late Directory dir;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('hive_test');
    Hive.init(dir.path);
  });

  tearDown(() async {
    for (final box in Hive.boxes.values) {
      await box.deleteFromDisk();
    }
    await Hive.close();
    await dir.delete(recursive: true);
  });

  test('Hive box can store and retrieve data', () async {
    final box = await Hive.openBox('testBox');
    await box.put('key', 'value');
    expect(box.get('key'), equals('value'));
  });
}
