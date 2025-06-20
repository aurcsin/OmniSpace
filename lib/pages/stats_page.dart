// File: lib/pages/stats_page.dart

import 'package:flutter/material.dart';

import '../models/zone_theme.dart';
import '../services/omni_note_service.dart';
import '../widgets/main_menu_drawer.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final notes = OmniNoteService.instance.notes;
    final byZone = {for (var z in ZoneTheme.values) z: 0};

    for (var n in notes) {
      byZone[n.zone] = (byZone[n.zone] ?? 0) + 1;
    }

    return Scaffold(
      drawer: const MainMenuDrawer(),
      appBar: AppBar(title: const Text('Stats')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Total Notes'),
            trailing: Text('${notes.length}'),
          ),
          const Divider(),
          ...ZoneTheme.values.map((zone) {
            return ListTile(
              title: Text(zone.name),              // use enum.name
              trailing: Text('${byZone[zone]}'),
            );
          }).toList(),
        ],
      ),
    );
  }
}
