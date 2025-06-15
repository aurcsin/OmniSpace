import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:omnispace/models/tracker.dart';
import 'package:omnispace/models/tracker_type.dart';
import 'package:omnispace/services/tracker_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_test');
    Hive.init(tempDir.path);
    await TrackerService.instance.init();
  });

  tearDown(() async {
    await Hive.deleteBoxFromDisk('trackers');
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  test('save and retrieve by id', () async {
    final t = Tracker(id: 't1', type: TrackerType.goal, title: 'test');
    await TrackerService.instance.save(t);
    expect(TrackerService.instance.byId('t1')?.title, 'test');
  });
}
