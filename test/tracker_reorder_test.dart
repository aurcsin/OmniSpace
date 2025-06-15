import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:omnispace/models/tracker.dart';
import 'package:omnispace/models/tracker_type.dart';
import 'package:omnispace/pages/tracker_page.dart';
import 'package:omnispace/services/tracker_service.dart';

Future<void> longPressDrag(
  WidgetTester tester,
  Finder finder,
  Offset offset,
) async {
  final start = tester.getCenter(finder);
  final gesture = await tester.startGesture(start);
  await tester.pump(const Duration(milliseconds: 500));
  await gesture.moveBy(offset);
  await tester.pump(const Duration(milliseconds: 500));
  await gesture.up();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('dragging reorders trackers', (WidgetTester tester) async {
    final dir = await Directory.systemTemp.createTemp();
    Hive.init(dir.path);
    Hive.registerAdapter(TrackerAdapter());
    Hive.registerAdapter(TrackerTypeAdapter());

    await TrackerService.instance.init();
    await TrackerService.instance.create(
      Tracker(id: '1', type: TrackerType.goal, title: 'A'),
    );
    await TrackerService.instance.create(
      Tracker(id: '2', type: TrackerType.goal, title: 'B'),
    );

    await tester.pumpWidget(const MaterialApp(home: TrackerPage()));
    expect(find.text('A'), findsOneWidget);
    expect(TrackerService.instance.ofType(TrackerType.goal).first.title, 'A');

    await longPressDrag(tester, find.text('A'), const Offset(0, 80));
    await tester.pumpAndSettle();

    expect(
      TrackerService.instance.ofType(TrackerType.goal).first.title,
      'B',
    );
  });
}
