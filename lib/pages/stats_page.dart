// lib/pages/stats_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../models/zone_theme.dart';
import '../services/omni_note_service.dart';
import '../widgets/main_menu_drawer.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final notes = OmniNoteService.instance.notes;
    // Initialize counts per realm
    final byZone = {for (var z in ZoneTheme.values) z: 0};

    // Count notes only where zone is set
    for (var n in notes) {
      if (n.zone != null) {
        byZone[n.zone!] = byZone[n.zone!]! + 1;
      }
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
              title: Text(describeEnum(zone)),
              trailing: Text('${byZone[zone]}'),
            );
          }).toList(),
        ],
      ),
    );
  }
}
