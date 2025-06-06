// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'models/omni_note.dart';
import 'services/omni_note_service.dart';
import 'pages/journal_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // -------------------------------------------------
  // 1) Initialize Hive for Flutter (only once)
  await Hive.initFlutter();

  // -------------------------------------------------
  // 2) Register both generated adapters (only here)
  Hive.registerAdapter(ZoneThemeAdapter());
  Hive.registerAdapter(OmniNoteAdapter());

  // -------------------------------------------------
  // 3) Open the box & load existing notes into memory
  await OmniNoteService.instance.initHive();

  // -------------------------------------------------
  // 4) Run the Flutter app, providing OmniNoteService
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => OmniNoteService.instance),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'OmniSpace',
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: JournalPage(),
      ),
    ),
  );
}
