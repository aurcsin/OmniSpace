// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'models/omni_note.dart';      // contains part 'omni_note.g.dart'
import 'models/attachment.dart';     // contains part 'attachment.g.dart'
import 'services/omni_note_service.dart';
import 'pages/journal_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // -------------------------------------------------
  // 1) Initialize Hive for Flutter (only once)
  await Hive.initFlutter();

  // -------------------------------------------------
  // 2) Register all generated adapters (only here!)
  Hive.registerAdapter(ZoneThemeAdapter());
  Hive.registerAdapter(OmniNoteAdapter());
  Hive.registerAdapter(AttachmentTypeAdapter());
  Hive.registerAdapter(AttachmentAdapter());

  // -------------------------------------------------
  // 3) Open the box & load existing notes into memory
  await OmniNoteService.instance.initHive();

  // -------------------------------------------------
  // 4) Run the app, providing OmniNoteService via Provider
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => OmniNoteService.instance),
        // You can also provide StatsService or other services if needed
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Ultimate Journal Hub',
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: JournalPage(),
      ),
    ),
  );
}
