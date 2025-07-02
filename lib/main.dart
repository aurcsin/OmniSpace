import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Models & Adapters
import 'models/omni_note.dart';
import 'models/zone_theme.dart';
import 'models/attachment.dart';
import 'models/tracker_type.dart';
import 'models/tracker.dart';
import 'models/tracker_collection.dart';
import 'models/project.dart';
import 'models/spirit.dart';  // <-- brings SpiritAdapter into scope

// Services
import 'services/timezone_helper_service.dart';
import 'services/notification_service.dart';
import 'services/sync_service.dart';
import 'services/omni_note_service.dart';
import 'services/tracker_service.dart';
import 'services/tracker_collection_service.dart';
import 'services/project_service.dart';
import 'services/spirit_service.dart';
import 'services/deck_service.dart';
import 'services/navigator_service.dart';

// Pages
import 'pages/journal_page.dart';
import 'pages/note_detail_page.dart';
import 'pages/note_view_page.dart';
import 'pages/spirit_page.dart';

// Themes / Utilities
import 'themes/theme_loader.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1) Initialize Hive
  await Hive.initFlutter();

  // 2) Debug: list which adapters are registered already
  for (var id = 0; id < 20; id++) {
    debugPrint('Hive adapter registered for typeId $id? ${Hive.isAdapterRegistered(id)}');
  }

  // 3) Register SpiritAdapter BEFORE opening any boxes
  if (!Hive.isAdapterRegistered(SpiritAdapter().typeId)) {
    debugPrint('Registering SpiritAdapter (typeId=${SpiritAdapter().typeId})');
    Hive.registerAdapter(SpiritAdapter());
  }
  debugPrint('After registration: SpiritAdapter registered? '
             '${Hive.isAdapterRegistered(SpiritAdapter().typeId)}');

  // 4) Quick sanity-check: open a test box and write one Spirit
  final testBox = await Hive.openBox<Spirit>('spirits_test');
  try {
    debugPrint('Opened testBox; adding dummy Spirit...');
    await testBox.add(Spirit(
      id: 'debug',
      name: 'Debug Spirit',
      mythos: 'Adapter test',
      purpose: 'Verifies Hive serialization',
      useInApp: 'N/A',
      realm: ZoneTheme.Air,
    ));
    debugPrint('Dummy Spirit added successfully!');
  } catch (e, st) {
    debugPrint('ERROR writing dummy Spirit: $e\n$st');
  }
  await testBox.clear();
  await testBox.close();

  // 5) Register the rest of your adapters
  if (!Hive.isAdapterRegistered(OmniNoteAdapter().typeId)) {
    Hive.registerAdapter(OmniNoteAdapter());
  }
  if (!Hive.isAdapterRegistered(ZoneThemeAdapter().typeId)) {
    Hive.registerAdapter(ZoneThemeAdapter());
  }
  if (!Hive.isAdapterRegistered(AttachmentAdapter().typeId)) {
    Hive.registerAdapter(AttachmentAdapter());
  }
  if (!Hive.isAdapterRegistered(TrackerTypeAdapter().typeId)) {
    Hive.registerAdapter(TrackerTypeAdapter());
  }
  if (!Hive.isAdapterRegistered(TrackerAdapter().typeId)) {
    Hive.registerAdapter(TrackerAdapter());
  }
  if (!Hive.isAdapterRegistered(TrackerCollectionAdapter().typeId)) {
    Hive.registerAdapter(TrackerCollectionAdapter());
  }
  if (!Hive.isAdapterRegistered(ProjectAdapter().typeId)) {
    Hive.registerAdapter(ProjectAdapter());
  }

  // 6) Initialize all services in proper order
  await TimezoneHelperService.instance.init();
  await NotificationService.instance.init();
  await OmniNoteService.instance.init();
  await TrackerService.instance.init();
  await TrackerCollectionService.instance.init();
  await ProjectService.instance.init();
  await SpiritService.instance.init();  // now Hive definitely knows Spirit
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
        '/spirits': (_) => const SpiritPage(),
      },
    );
  }
}
