// lib/main.dart

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Models & Adapters
import 'package:omnispace/models/omni_note.dart';
import 'package:omnispace/models/zone_theme.dart';
import 'package:omnispace/models/attachment.dart';
import 'package:omnispace/models/tracker_type.dart';
import 'package:omnispace/models/tracker.dart';
import 'package:omnispace/models/tracker_collection.dart';
import 'package:omnispace/models/project.dart';
import 'package:omnispace/models/note_collection.dart';
import 'package:omnispace/models/spirit.dart';
import 'package:omnispace/models/deck.dart';

// Services
import 'package:omnispace/services/notification_service.dart';
import 'package:omnispace/services/omni_note_service.dart';
import 'package:omnispace/services/tracker_service.dart';
import 'package:omnispace/services/tracker_collection_service.dart';
import 'package:omnispace/services/project_service.dart';
import 'package:omnispace/services/note_collection_service.dart';
import 'package:omnispace/services/spirit_service.dart';
import 'package:omnispace/services/deck_service.dart';
import 'package:omnispace/services/sync_service.dart';
import 'package:omnispace/services/navigator_service.dart';

import 'package:omnispace/themes/theme_loader.dart';
import 'package:omnispace/pages/journal_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize Hive for Flutter
  await Hive.initFlutter();

  // 2. Register ALL adapters, but only if not already registered
  final adapters = <int, TypeAdapter>{
    OmniNoteAdapter().typeId:         OmniNoteAdapter(),
    ZoneThemeAdapter().typeId:        ZoneThemeAdapter(),
    AttachmentAdapter().typeId:       AttachmentAdapter(),
    TrackerTypeAdapter().typeId:      TrackerTypeAdapter(),
    TrackerAdapter().typeId:          TrackerAdapter(),
    TrackerCollectionAdapter().typeId:TrackerCollectionAdapter(),
    ProjectAdapter().typeId:          ProjectAdapter(),
    NoteCollectionAdapter().typeId:   NoteCollectionAdapter(),
    SpiritAdapter().typeId:           SpiritAdapter(),
    DeckAdapter().typeId:             DeckAdapter(),
  };
  for (final entry in adapters.entries) {
    if (!Hive.isAdapterRegistered(entry.key)) {
      Hive.registerAdapter(entry.value);
    }
  }

  // 3. Initialize every Hive-backed service before runApp()
  await NotificationService.instance.init();
  await OmniNoteService.instance.init();
  await TrackerService.instance.init();
  await TrackerCollectionService.instance.init();
  await ProjectService.instance.init();
  await NoteCollectionService.instance.init();
  await SpiritService.instance.init();
  await DeckService.instance.init();
  await SyncService.instance.init();

  // 4. Finally run the app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
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
