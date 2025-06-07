import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'models/omni_note.dart';
import 'models/attachment.dart';
import 'models/day_reflection.dart';
import 'models/task.dart';
import 'models/goal.dart';
import 'models/event.dart';
import 'models/media_attachment.dart';

import 'services/omni_note_service.dart';
import 'services/day_reflection_service.dart';

import 'pages/journal_page.dart';
import 'pages/trackers_page.dart';
import 'pages/media_page.dart';
import 'pages/root_cave_page.dart';
import 'pages/workshop_forge_page.dart';
import 'pages/studio_underwater_page.dart';
import 'pages/sky_space_page.dart';
import 'pages/garden_forest_page.dart';
import 'pages/collections_page.dart';
import 'pages/options_page.dart';
import 'pages/account_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register adapters in ascending order of typeId
  Hive.registerAdapter(ZoneThemeAdapter());         // if you have a ZoneTheme enum
  Hive.registerAdapter(OmniNoteAdapter());
  Hive.registerAdapter(AttachmentTypeAdapter());
  Hive.registerAdapter(AttachmentAdapter());
  Hive.registerAdapter(MediaAttachmentAdapter());
  Hive.registerAdapter(DayReflectionAdapter());
  Hive.registerAdapter(TaskAdapter());
  Hive.registerAdapter(GoalAdapter());
  Hive.registerAdapter(EventAdapter());

  // Initialize your services (open boxes, etc.)
  await OmniNoteService.instance.init();
  await DayReflectionService.instance.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OmniSpace',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      initialRoute: '/journal',
      routes: {
        '/journal': (_) => const JournalPage(),
        '/trackers': (_) => const TrackersPage(),
        '/media': (_) => const MediaPage(),
        '/root-cave': (_) => const RootCavePage(),
        '/forge': (_) => const WorkshopForgePage(),
        '/studio': (_) => const StudioUnderwaterPage(),
        '/sky': (_) => const SkySpacePage(),
        '/garden': (_) => const GardenForestPage(),
        '/collections': (_) => const CollectionsPage(),
        '/options': (_) => const OptionsPage(),
        '/account': (_) => const AccountPage(),
      },
    );
  }
}
