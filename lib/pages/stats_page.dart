import 'package:flutter/material.dart';

import 'package:omnispace/models/zone_theme.dart';
import 'package:omnispace/services/omni_note_service.dart';
import 'package:omnispace/widgets/main_menu_drawer.dart';
import '../extensions/zone_theme_extensions.dart';

/// Shows overall statistics about notes by zone.
class StatsPage extends StatelessWidget {
  const StatsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final notes = OmniNoteService.instance.notes;
    // Initialize counts for each zone
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
          // Display count per zone
          ...ZoneTheme.values.map(
            (z) => ListTile(
              title: Text(z.label),
              trailing: Text('${byZone[z]}'),
            ),
          ),
        ],
      ),
    );
  }
}
