import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:omnispace/models/tracker.dart';
import 'package:omnispace/models/tracker_type.dart';
import 'package:omnispace/services/tracker_service.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('tracker_test');
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(TrackerAdapter().typeId)) {
      Hive.registerAdapter(TrackerAdapter());
    }
    if (!Hive.isAdapterRegistered(TrackerTypeAdapter().typeId)) {
      Hive.registerAdapter(TrackerTypeAdapter());
    }
    await TrackerService.instance.init();
  });

  tearDown(() async {
    await Hive.box<Tracker>('trackers').close();
    await Hive.deleteBoxFromDisk('trackers');
    await tempDir.delete(recursive: true);
  });

  test('byId returns saved tracker', () async {
    final tracker = Tracker(
      id: 't1',
      type: TrackerType.goal,
      title: 'Test Tracker',
    );
    await TrackerService.instance.save(tracker);

    final fetched = TrackerService.instance.byId('t1');
    expect(fetched, isNotNull);
    expect(fetched!.title, equals('Test Tracker'));
  });
}
