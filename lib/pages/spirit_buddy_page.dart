import 'package:flutter/material.dart';

import '../models/omni_note.dart';
import '../services/omni_note_service.dart';
import '../services/spirit_buddy_service.dart';
import '../widgets/main_menu_drawer.dart';

class SpiritBuddyPage extends StatefulWidget {
  const SpiritBuddyPage({super.key});

  @override
  _SpiritBuddyPageState createState() => _SpiritBuddyPageState();
}

class _SpiritBuddyPageState extends State<SpiritBuddyPage> {
  String _message = '';

  void _reflectOn(OmniNote note) {
    SpiritBuddyService.instance.reflectOnEntry(note);
    setState(() {
      _message = 'Reflected on "${note.title}"';
    });
  }

  @override
  Widget build(BuildContext context) {
    final notes = OmniNoteService.instance.notes;
    return Scaffold(
      appBar: AppBar(title: const Text('Spirit Buddy')),
      drawer: const MainMenuDrawer(),
      body: Column(
        children: [
          if (_message.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(_message),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: notes.length,
              itemBuilder: (_, i) {
                final n = notes[i];
                return ListTile(
                  title: Text(n.title.isNotEmpty ? n.title : '(No Title)'),
                  onTap: () => _reflectOn(n),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
