// File: lib/main.dart

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'models/omni_note.dart';
import 'models/zone_theme.dart';
import 'models/attachment.dart';
import 'models/tracker_type.dart';
import 'models/tracker.dart';
import 'models/tracker_collection.dart';
import 'models/project.dart';
import 'models/spirit.dart';
import 'models/deck.dart';

import 'services/notification_service.dart';
import 'services/omni_note_service.dart';
import 'services/tracker_service.dart';
import 'services/tracker_collection_service.dart';
import 'services/project_service.dart';
import 'services/spirit_service.dart';
import 'services/deck_service.dart';
import 'services/navigator_service.dart';

import 'themes/theme_loader.dart';
import 'pages/journal_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // Nuke any old boxes so nothing is mis‐typed:
  await Hive.deleteBoxFromDisk('omni_notes').catchError((_) {});
  await Hive.deleteBoxFromDisk('spirits').catchError((_) {});
  await Hive.deleteBoxFromDisk('decks').catchError((_) {});

  // Register exactly one adapter per typeId:
  final adapters = <TypeAdapter<dynamic>>[
    OmniNoteAdapter(),
    ZoneThemeAdapter(),
    AttachmentAdapter(),
    TrackerTypeAdapter(),
    TrackerAdapter(),
    TrackerCollectionAdapter(),
    ProjectAdapter(),
    SpiritAdapter(),
    DeckAdapter(),
  ];
  for (final adapter in adapters) {
    if (!Hive.isAdapterRegistered(adapter.typeId)) {
      Hive.registerAdapter(adapter);
    }
  }

  // Now open each box in turn (no accidental cross‐writes):
  await NotificationService.instance.init();
  await OmniNoteService.instance.init();        // opens 'omni_notes'
  await TrackerService.instance.init();         // opens 'trackers'
  await TrackerCollectionService.instance.init();
  await ProjectService.instance.init();
  await SpiritService.instance.init();          // opens 'spirits'
  await DeckService.instance.init();            // opens 'decks'

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OmniSpace',
      theme: ThemeLoader.load('default'),
      home: const JournalPage(),
      navigatorKey: NavigatorService.instance.navigatorKey,
    );
  }
}
