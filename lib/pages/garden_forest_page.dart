// File: lib/pages/garden_forest_page.dart

import 'package:flutter/material.dart';

import '../models/omni_note.dart';
import '../models/zone_theme.dart';
import '../services/omni_note_service.dart';
import 'multi_pane_editor_page.dart';

class GardenForestPage extends StatelessWidget {
  const GardenForestPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Garden • Forest'),
      ),
      body: FutureBuilder<List<OmniNote>>(
        future: OmniNoteService.instance.all,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final notes = snap.data!
              .where((n) =>
                  n.zone == ZoneTheme.Earth &&
                  !n.isTrashed &&
                  !n.isArchived)
              .toList();

          if (notes.isEmpty) {
            return const Center(child: Text('No "Earth/Forest" notes yet.'));
          }

          return Padding(
            padding: const EdgeInsets.all(8),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: notes.length,
              itemBuilder: (context, i) {
                final n = notes[i];
                return GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => MultiPaneEditorPage(n)),
                  ),
                  child: Card(
                    elevation: 4,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.local_florist,
                          size: 48,
                          color: Color(n.colorValue),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          n.title.isEmpty ? '(No title)' : n.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
