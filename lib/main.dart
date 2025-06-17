// File: lib/main.dart

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Models & Adapters
import 'models/omni_note.dart';
import 'models/attachment.dart';
import 'models/task.dart';
import 'models/goal.dart';
import 'models/event.dart';
import 'models/day_reflection.dart';
import 'models/tracker_type.dart';
import 'models/tracker.dart';
import 'models/sync_metadata.dart';
import 'models/settings.dart';
import 'models/user_profile.dart';
import 'models/project.dart';
import 'models/tracker_collection.dart';

// Services
import 'services/notification_service.dart';
import 'services/tracker_service.dart';
import 'services/omni_note_service.dart';
import 'services/day_reflection_service.dart';
import 'services/task_service.dart';
import 'services/goal_service.dart';
import 'services/event_service.dart';
import 'services/user_profile_service.dart';
import 'services/project_service.dart';
import 'services/tracker_collection_service.dart';

// Pages
import 'pages/journal_page.dart';
import 'pages/omni_tracker_page.dart';
import 'pages/media_page.dart';
import 'pages/calendar_overview_page.dart';
import 'pages/day_reflection_page.dart';
import 'pages/multi_pane_editor_page.dart';
import 'pages/workshop_forge_page.dart';
import 'pages/tracker_detail_page.dart';

// Navigator & Themes
import 'services/navigator_service.dart';
import 'themes/theme_loader.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // Explicitly register each adapter:
  if (!Hive.isAdapterRegistered(OmniNoteAdapter().typeId)) {
    Hive.registerAdapter(OmniNoteAdapter());
  }
  if (!Hive.isAdapterRegistered(AttachmentAdapter().typeId)) {
    Hive.registerAdapter(AttachmentAdapter());
  }
  if (!Hive.isAdapterRegistered(TaskAdapter().typeId)) {
    Hive.registerAdapter(TaskAdapter());
  }
  if (!Hive.isAdapterRegistered(GoalAdapter().typeId)) {
    Hive.registerAdapter(GoalAdapter());
  }
  if (!Hive.isAdapterRegistered(EventAdapter().typeId)) {
    Hive.registerAdapter(EventAdapter());
  }
  if (!Hive.isAdapterRegistered(DayReflectionAdapter().typeId)) {
    Hive.registerAdapter(DayReflectionAdapter());
  }
  if (!Hive.isAdapterRegistered(TrackerTypeAdapter().typeId)) {
    Hive.registerAdapter(TrackerTypeAdapter());
  }
  if (!Hive.isAdapterRegistered(TrackerAdapter().typeId)) {
    Hive.registerAdapter(TrackerAdapter());
  }
  if (!Hive.isAdapterRegistered(SyncMetadataAdapter().typeId)) {
    Hive.registerAdapter(SyncMetadataAdapter());
  }
  if (!Hive.isAdapterRegistered(SettingsAdapter().typeId)) {
    Hive.registerAdapter(SettingsAdapter());
  }
  if (!Hive.isAdapterRegistered(UserProfileAdapter().typeId)) {
    Hive.registerAdapter(UserProfileAdapter());
  }
  if (!Hive.isAdapterRegistered(ProjectAdapter().typeId)) {
    Hive.registerAdapter(ProjectAdapter());
  }
  if (!Hive.isAdapterRegistered(TrackerCollectionAdapter().typeId)) {
    Hive.registerAdapter(TrackerCollectionAdapter());
  }

  // Initialize all services in order
  await NotificationService.instance.init();
  await TrackerService.instance.init();
  await OmniNoteService.instance.init();
  await DayReflectionService.instance.init();
  await TaskService.instance.init();
  await GoalService.instance.init();
  await EventService.instance.init();
  await UserProfileService.instance.init();
  await ProjectService.instance.init();
  await TrackerCollectionService.instance.init();

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
        '/omnitracker': (_) => const OmniTrackerPage(),
        '/media': (_) => const MediaPage(),
        '/calendar': (_) => const CalendarOverviewPage(),
        '/reflections': (_) => const DayReflectionPage(),
        '/editor': (_) => const MultiPaneEditorPage(),
        '/forge': (_) => const WorkshopForgePage(),
        '/trackerDetail': (ctx) {
          final arg = ModalRoute.of(ctx)!.settings.arguments;
          final tracker = (arg is Tracker)
              ? arg
              : TrackerService.instance.all
                  .firstWhere((t) => t.id == arg as String);
          return TrackerDetailPage(tracker: tracker);
        },
      },
    );
  }
}
