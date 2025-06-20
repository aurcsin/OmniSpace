// test/widget_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:omnispace/pages/journal_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('JournalPage renders without error', (WidgetTester tester) async {
    // Wrap JournalPage in a MaterialApp so it has a Navigator/Theme/etc.
    await tester.pumpWidget(
      const MaterialApp(
        home: JournalPage(),
      ),
    );

    // Let any animations/async work settle
    await tester.pumpAndSettle();

    // Verify that JournalPage is present
    expect(find.byType(JournalPage), findsOneWidget);
  });
}
