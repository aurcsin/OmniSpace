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
import 'services/project_service.dart';
import 'services/tracker_service.dart';
import 'services/tracker_collection_service.dart';
import 'services/spirit_service.dart';
import 'services/deck_service.dart';

import 'pages/journal_page.dart';
import 'pages/note_detail_page.dart';
import 'pages/note_view_page.dart';
import 'pages/projects_page.dart';
import 'pages/spirit_page.dart';
import 'pages/deck_page.dart';

import 'themes/theme_loader.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register all adapters before opening any boxes
  Hive.registerAdapter(OmniNoteAdapter());
  Hive.registerAdapter(ZoneThemeAdapter());
  Hive.registerAdapter(AttachmentAdapter());
  Hive.registerAdapter(TrackerTypeAdapter());
  Hive.registerAdapter(TrackerAdapter());
  Hive.registerAdapter(TrackerCollectionAdapter());
  Hive.registerAdapter(ProjectAdapter());
  Hive.registerAdapter(SpiritAdapter());
  Hive.registerAdapter(DeckAdapter());

  // Initialize services (each opens its own Hive box)
  await NotificationService.instance.init();
  await OmniNoteService.instance.init();
  await ProjectService.instance.init();
  await TrackerService.instance.init();
  await TrackerCollectionService.instance.init();
  await SpiritService.instance.init();
  await DeckService.instance.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OmniSpace',
      theme: ThemeLoader.load('light'),
      initialRoute: '/journal',
      routes: {
        '/journal': (_) => const JournalPage(),
        '/noteDetail': (ctx) {
          final note = ModalRoute.of(ctx)!.settings.arguments as OmniNote?;
          return NoteDetailPage(omniNote: note);
        },
        '/noteView': (ctx) {
          final note = ModalRoute.of(ctx)!.settings.arguments as OmniNote;
          return NoteViewPage(note: note);
        },
        '/projects': (_) => const ProjectsPage(),
        '/spirits':  (_) => const SpiritPage(),
        '/deck':     (_) => const DeckPage(),
        // …other routes…
      },
      onGenerateRoute: (settings) {
        // handle dynamic or parameterized routes here if needed
        return null;
      },
    );
  }
}
