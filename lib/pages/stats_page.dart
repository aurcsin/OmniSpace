import 'package:flutter/material.dart';

import '../models/omni_note.dart';
import '../services/omni_note_service.dart';
import '../widgets/main_menu_drawer.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final notes = OmniNoteService.instance.notes;
    final byZone = {for (var z in ZoneTheme.values) z: 0};
    for (var n in notes) {
      byZone[n.zone] = byZone[n.zone]! + 1;
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Stats')),
      drawer: const MainMenuDrawer(),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Total Notes'),
            trailing: Text('${notes.length}'),
          ),
          const Divider(),
          ...ZoneTheme.values.map(
            (z) => ListTile(
              title: Text(z.toString().split('.').last),
              trailing: Text('${byZone[z]}'),
            ),
          ),
        ],
      ),
    );
  }
}
