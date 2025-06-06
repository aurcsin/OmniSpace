import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:omnispace/models/omni_note.dart';
import 'package:omnispace/pages/journal_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(OmniNoteAdapter());
  await Hive.openBox<OmniNote>('omni_notes');

  runApp(const OmniSpaceApp());
}

class OmniSpaceApp extends StatelessWidget {
  const OmniSpaceApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OmniSpace',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.teal),
      home: const JournalPage(),
    );
  }
}
