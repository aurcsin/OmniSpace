// lib/main.dart

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'models/omni_note.dart';
import 'models/attachment.dart';
import 'services/omni_note_service.dart';
import 'pages/journal_page.dart';

Future<void> main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive and HiveFlutter
  await Hive.initFlutter();

  // Register all generated adapters
  Hive.registerAdapter(ZoneThemeAdapter());
  Hive.registerAdapter(OmniNoteAdapter());
  Hive.registerAdapter(AttachmentTypeAdapter());
  Hive.registerAdapter(AttachmentAdapter());

  // Open your notes box (or perform any other startup work)
  await OmniNoteService.instance.init();

  // Run the app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OmniSpace',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const JournalPage(),
    );
  }
}
