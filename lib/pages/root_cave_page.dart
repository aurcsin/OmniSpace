// File: lib/pages/root_cave_page.dart

import 'package:flutter/material.dart';

import '../models/omni_note.dart';
import '../services/omni_note_service.dart';
import 'multi_pane_editor_page.dart';

class RootCavePage extends StatelessWidget {
  const RootCavePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Root Cave • Underground'),
      ),
      body: FutureBuilder<List<OmniNote>>(
        future: OmniNoteService.instance.all,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final notes = snap.data!;
          final archived =
              notes.where((n) => n.isArchived && !n.isTrashed).toList();
          final trashed = notes.where((n) => n.isTrashed).toList();

          return ListView(
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Archived Entries',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              if (archived.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('No archived notes.'),
                )
              else
                ...archived.map((n) => ListTile(
                      title: Text(n.title.isEmpty ? '(No title)' : n.title),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => MultiPaneEditorPage(n)),
                      ),
                    )),
              const Divider(),
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Trash',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              if (trashed.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Trash is empty.'),
                )
              else
                ...trashed.map((n) => ListTile(
                      title: Text(n.title.isEmpty ? '(No title)' : n.title),
                      subtitle: const Text('Trashed'),
                      trailing: IconButton(
                        icon: const Icon(Icons.restore),
                        onPressed: () async {
                          await OmniNoteService.instance.restoreNote(n.id);
                          (context as Element).markNeedsBuild();
                        },
                      ),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => MultiPaneEditorPage(n)),
                      ),
                    )),
            ],
          );
        },
      ),
    );
  }
}
