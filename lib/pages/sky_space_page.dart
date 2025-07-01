// File: lib/pages/sky_space_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/omni_note.dart';
import '../models/zone_theme.dart';
import '../services/omni_note_service.dart';
import 'multi_pane_editor_page.dart';

class SkySpacePage extends StatelessWidget {
  const SkySpacePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sky • Space'),
      ),
      body: FutureBuilder<List<OmniNote>>(
        future: OmniNoteService.instance.all,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final notes = snap.data!
              .where((n) =>
                  n.zone == ZoneTheme.Air &&
                  !n.isTrashed &&
                  !n.isArchived)
              .toList()
            ..sort((a, b) => b.lastUpdated.compareTo(a.lastUpdated));

          if (notes.isEmpty) {
            return const Center(child: Text('No "Air/Space" notes yet.'));
          }

          return ListView.builder(
            itemCount: notes.length,
            itemBuilder: (context, i) {
              final n = notes[i];
              return ListTile(
                title: Text(n.title.isEmpty ? '(No title)' : n.title),
                subtitle:
                    Text(DateFormat.yMMMd().add_jm().format(n.lastUpdated)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => MultiPaneEditorPage(n)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
