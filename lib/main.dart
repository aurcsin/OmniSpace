// File: lib/main.dart

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Models
import 'package:omnispace/models/omni_note.dart';
import 'package:omnispace/models/attachment.dart';
import 'package:omnispace/models/task.dart';
import 'package:omnispace/models/goal.dart';
import 'package:omnispace/models/event.dart';
import 'package:omnispace/models/day_reflection.dart';
import 'package:omnispace/models/tracker_type.dart';
import 'package:omnispace/models/tracker.dart';
import 'package:omnispace/models/sync_metadata.dart';
import 'package:omnispace/models/settings.dart';
import 'package:omnispace/models/user_profile.dart';

// Services
import 'package:omnispace/services/notification_service.dart';
import 'package:omnispace/services/tracker_service.dart';
import 'package:omnispace/services/omni_note_service.dart';
import 'package:omnispace/services/day_reflection_service.dart';
import 'package:omnispace/services/task_service.dart';
import 'package:omnispace/services/user_profile_service.dart';

// Pages
import 'package:omnispace/pages/journal_page.dart';
import 'package:omnispace/pages/tracker_page.dart';
import 'package:omnispace/pages/media_page.dart';
import 'package:omnispace/pages/calendar_overview_page.dart';
import 'package:omnispace/pages/day_reflection_page.dart';
import 'package:omnispace/pages/multi_pane_editor_page.dart';
import 'package:omnispace/pages/workshop_forge_page.dart';
import 'package:omnispace/pages/tracker_detail_page.dart';
import 'package:omnispace/services/navigator_service.dart';
import 'themes/theme_loader.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // Register Hive adapters only once
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

  // Initialize services
  await NotificationService.instance.init();
  await TrackerService.instance.init();
  await OmniNoteService.instance.init();
  await DayReflectionService.instance.init();
  await TaskService.instance.init();
  await UserProfileService.instance.init();

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
        '/tracker': (_) => const TrackerPage(),
        '/media': (_) => const MediaPage(),
        '/calendar': (_) => const CalendarOverviewPage(),
        '/reflections': (_) => const DayReflectionPage(),
        '/editor': (_) => const MultiPaneEditorPage(),
        '/forge': (_) => const WorkshopForgePage(),
        '/trackerDetail': (ctx) {
          final arg = ModalRoute.of(ctx)!.settings.arguments;
          Tracker tracker;
          if (arg is Tracker) {
            tracker = arg;
          } else if (arg is String) {
            tracker = TrackerService.instance.all.firstWhere((t) => t.id == arg);
          } else {
            throw ArgumentError('Tracker or tracker id required');
          }
          return TrackerDetailPage(tracker: tracker);
        },
      },
    );
  }
}
