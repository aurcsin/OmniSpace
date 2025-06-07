import 'package:flutter/material.dart';
import '../models/omni_note.dart';
import '../services/omni_note_service.dart';
import '../widgets/main_menu_drawer.dart';

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
          final color = _zoneColor(n.zone);
          return Icon(Icons.local_florist, color: color, size: 32);
        },
      ),
    );
  }

  Color _zoneColor(ZoneTheme z) {
    switch (z) {
      case ZoneTheme.Air:
        return Colors.lightBlue;
      case ZoneTheme.Earth:
        return Colors.brown;
      case ZoneTheme.Fire:
        return Colors.red;
      case ZoneTheme.Water:
        return Colors.blueAccent;
      case ZoneTheme.Void:
        return Colors.grey;
      case ZoneTheme.Fusion:
        return Colors.purple;
    }
  }
}
