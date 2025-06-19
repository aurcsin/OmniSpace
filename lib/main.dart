import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Models
import 'models/omni_note.dart';
import 'models/attachment.dart';
import 'models/tracker_type.dart';
import 'models/tracker.dart';
import 'models/tracker_collection.dart';
// ... (other model imports)

// Services
import 'services/omni_note_service.dart';
import 'services/tracker_service.dart';
import 'services/tracker_collection_service.dart';
import 'services/notification_service.dart';
import 'services/navigator_service.dart';

// Pages
import 'pages/journal_page.dart';
import 'pages/note_detail_page.dart';
import 'pages/note_view_page.dart';
// ... (other page imports)

import 'themes/theme_loader.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // Register ALL adapters before opening boxes:
  Hive.registerAdapter(OmniNoteAdapter());
  Hive.registerAdapter(ZoneThemeAdapter());
  Hive.registerAdapter(AttachmentAdapter());
  Hive.registerAdapter(TrackerTypeAdapter());
  Hive.registerAdapter(TrackerAdapter());
  Hive.registerAdapter(TrackerCollectionAdapter());
  // ... (any other adapters)

  // Initialize services (and open boxes)
  await NotificationService.instance.init();
  await OmniNoteService.instance.init();
  await TrackerService.instance.init();
  await TrackerCollectionService.instance.init();
  // ... (other service inits)

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
        // ... (other routes)
      },
    );
  }
}
