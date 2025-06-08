import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'models/omni_note.dart';
import 'models/attachment.dart';
import 'models/day_reflection.dart';
import 'models/task.dart';
import 'models/goal.dart';
import 'models/event.dart';

import 'services/omni_note_service.dart';
import 'services/day_reflection_service.dart';
import 'services/task_service.dart';

import 'pages/journal_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register adapters in ascending order of typeId
  Hive.registerAdapter(ZoneThemeAdapter());         // if you have a ZoneTheme enum
  Hive.registerAdapter(OmniNoteAdapter());
  Hive.registerAdapter(AttachmentTypeAdapter());
  Hive.registerAdapter(AttachmentAdapter());
  Hive.registerAdapter(DayReflectionAdapter());
  Hive.registerAdapter(TaskAdapter());
  Hive.registerAdapter(GoalAdapter());
  Hive.registerAdapter(EventAdapter());

  // Initialize your services (open boxes, etc.)
  await OmniNoteService.instance.init();
  await DayReflectionService.instance.init();
  await TaskService.instance.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OmniSpace',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: const JournalPage(),
    );
  }
}
