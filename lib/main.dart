import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

// ─── Hive Adapters ─────────────────────────────────────────────────────────────
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

// ─── Services ─────────────────────────────────────────────────────────────────
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

// ─── Pages ────────────────────────────────────────────────────────────────────
// User Logs
import 'package:omnispace/pages/journal_page.dart';
import 'package:omnispace/pages/omni_tracker_page.dart';
import 'package:omnispace/pages/projects_page.dart';
import 'package:omnispace/pages/collections_page.dart';
import 'package:omnispace/pages/calendar_overview_page.dart';

// Spirit Board
import 'package:omnispace/pages/alignment_page.dart';
import 'package:omnispace/pages/deck_page.dart';
import 'package:omnispace/pages/spirit_hall_page.dart';
import 'package:omnispace/pages/fusion_chamber_page.dart';
import 'package:omnispace/pages/stats_page.dart';

// Elementals
import 'package:omnispace/pages/sky_space_page.dart';
import 'package:omnispace/pages/workshop_forge_page.dart';
import 'package:omnispace/pages/garden_forest_page.dart';
import 'package:omnispace/pages/studio_underwater_page.dart';
import 'package:omnispace/pages/root_cave_page.dart';

// Account & Settings
import 'package:omnispace/pages/account_page.dart';
import 'package:omnispace/pages/settings_page.dart';
import 'package:omnispace/pages/trash_page.dart';
import 'package:omnispace/pages/about_page.dart';

// Note Detail
import 'package:omnispace/pages/note_detail_page.dart';

// ─── Drawer ───────────────────────────────────────────────────────────────────
import 'package:omnispace/widgets/main_menu_drawer.dart';

import 'package:omnispace/themes/theme_loader.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // Register all Hive adapters
  final adapters = <int, TypeAdapter<dynamic>>{
    OmniNoteAdapter().typeId:          OmniNoteAdapter(),
    ZoneThemeAdapter().typeId:         ZoneThemeAdapter(),
    AttachmentAdapter().typeId:        AttachmentAdapter(),
    TrackerTypeAdapter().typeId:       TrackerTypeAdapter(),
    TrackerAdapter().typeId:           TrackerAdapter(),
    TrackerCollectionAdapter().typeId: TrackerCollectionAdapter(),
    ProjectAdapter().typeId:           ProjectAdapter(),
    NoteCollectionAdapter().typeId:    NoteCollectionAdapter(),
    SpiritAdapter().typeId:            SpiritAdapter(),
    DeckAdapter().typeId:              DeckAdapter(),
  };
  for (var a in adapters.values) {
    if (!Hive.isAdapterRegistered(a.typeId)) {
      Hive.registerAdapter(a);
    }
  }

  // Initialize all services
  await NotificationService.instance.init();
  await OmniNoteService.instance.init();
  await TrackerService.instance.init();
  await TrackerCollectionService.instance.init();
  await ProjectService.instance.init();
  await NoteCollectionService.instance.init();
  await SpiritService.instance.init();
  await DeckService.instance.init();
  await SyncService.instance.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OmniSpace',
      theme: ThemeLoader.load('default'),
      navigatorKey: NavigatorService.instance.navigatorKey,
      initialRoute: '/journal',
      routes: {
        // ─── User Logs ────────────────────────────────────────────
        '/journal':     (_) => const JournalPage(),
        '/trackers':    (_) => const OmniTrackerPage(),
        '/projects':    (_) => const ProjectsPage(),
        '/collections': (_) => const CollectionsPage(),
        '/calendar':    (_) => const CalendarOverviewPage(),

        // ─── Spirit Board ────────────────────────────────────────
        '/alignment':   (_) => const AlignmentPage(),
        '/deck':        (_) => const DeckPage(),
        '/spirithall':  (_) => const SpiritHallPage(),
        '/fusion':      (_) => const FusionChamberPage(),
        '/stats':       (_) => const StatsPage(),

        // ─── Elementals ──────────────────────────────────────────
        '/sky':         (_) => const SkySpacePage(),
        '/forge':       (_) => const WorkshopForgePage(),
        '/forest':      (_) => const GardenForestPage(),
        '/underwater':  (_) => const StudioUnderwaterPage(),
        '/cave':        (_) => const RootCavePage(),

        // ─── Account & Settings ─────────────────────────────────
        '/account':     (_) => const AccountPage(),
        '/settings':    (_) => const SettingsPage(),
        '/trash':       (_) => const TrashPage(),
        '/about':       (_) => const AboutPage(),

        // ─── Note Detail ────────────────────────────────────────
        '/note':        (_) => const NoteDetailPage(),
      },
    );
  }
}
