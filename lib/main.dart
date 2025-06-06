// lib/main.dart

import 'package:flutter/material.dart';
import 'pages/journal_page.dart'; // relative import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const OmniSpaceApp());
}

class OmniSpaceApp extends StatelessWidget {
  const OmniSpaceApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OmniSpace',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // Remove `const` here because JournalPage() is not a const constructor
      home: JournalPage(),
    );
  }
}
