import 'package:flutter/material.dart';
import '../services/omni_note_service.dart';
import '../widgets/main_menu_drawer.dart';
import '../extensions/zone_theme_extensions.dart';


class GardenForestPage extends StatelessWidget {
  const GardenForestPage({super.key});

  @override
  Widget build(BuildContext context) {
    final notes = OmniNoteService.instance.notes;
    return Scaffold(
      appBar: AppBar(title: const Text('Garden / Forest')),
      drawer: const MainMenuDrawer(),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
        itemCount: notes.length,
        itemBuilder: (_, i) {
          final n = notes[i];
          // Use the extension to fetch the zone color:
          return Icon(
            Icons.local_florist,
            color: n.zone.color,
            size: 32,
          );
        },
      ),
    );
  }
}
