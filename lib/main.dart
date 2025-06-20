import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Models & Adapters
import 'models/omni_note.dart';
import 'models/zone_theme.dart';
import 'models/attachment.dart';
import 'models/tracker_type.dart';
import 'models/tracker.dart';
import 'models/tracker_collection.dart';
// … other @HiveType models …

// Services
import 'services/notification_service.dart';
import 'services/omni_note_service.dart';
import 'services/tracker_service.dart';
import 'services/tracker_collection_service.dart';
import 'services/navigator_service.dart';
// … other services …

// Pages
import 'pages/journal_page.dart';
import 'pages/note_detail_page.dart';
import 'pages/note_view_page.dart';
// … other pages …

// Themes / Utilities
import 'themes/theme_loader.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register EVERY adapter before opening any boxes:
  Hive.registerAdapter(OmniNoteAdapter());
  Hive.registerAdapter(ZoneThemeAdapter());
  Hive.registerAdapter(AttachmentAdapter());
  Hive.registerAdapter(TrackerTypeAdapter());
  Hive.registerAdapter(TrackerAdapter());
  Hive.registerAdapter(TrackerCollectionAdapter());
  // … register other generated adapters …

  // Initialize services (they open their Hive boxes internally)
  await NotificationService.instance.init();
  await OmniNoteService.instance.init();
  await TrackerService.instance.init();
  await TrackerCollectionService.instance.init();
  // … other service inits …

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OmniSpace',
      theme: ThemeLoader.load('light'),
      navigatorKey: NavigatorService.instance.navigatorKey,
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
        // Add additional routes here…
      },
    );
  }
}
