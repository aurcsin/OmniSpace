import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:omnispace/models/tracker.dart';
import 'package:omnispace/models/tracker_type.dart';
import 'package:omnispace/services/tracker_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory dir;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('hive_test');
    Hive.init(dir.path);
    await TrackerService.instance.init();
    await TrackerService.instance.create(
        Tracker(id: '1', type: TrackerType.goal, title: 'A'));
    await TrackerService.instance.create(
        Tracker(id: '2', type: TrackerType.goal, title: 'B'));
    await TrackerService.instance.create(
        Tracker(id: '3', type: TrackerType.goal, title: 'C'));
  });

  tearDown(() async {
    if (Hive.isBoxOpen('trackers')) {
      await Hive.box('trackers').close();
    }
    if (Hive.isBoxOpen('tracker_links')) {
      await Hive.box('tracker_links').close();
    }
    await Hive.deleteBoxFromDisk('trackers');
    await Hive.deleteBoxFromDisk('tracker_links');
    await dir.delete(recursive: true);
  });

  test('reorder persists new order', () async {
    await TrackerService.instance.reorder(TrackerType.goal, 0, 2);
    final titles = TrackerService.instance
        .ofType(TrackerType.goal)
        .map((t) => t.title)
        .toList();
    expect(titles, ['B', 'C', 'A']);
  });
}
