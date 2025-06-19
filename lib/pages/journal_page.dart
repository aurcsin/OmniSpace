import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/omni_note.dart';
import '../models/project.dart';
import '../services/omni_note_service.dart';
import '../services/project_service.dart';
import '../widgets/main_menu_drawer.dart';
import 'note_detail_page.dart';

class JournalPage extends StatefulWidget {
  const JournalPage({Key? key}) : super(key: key);

  @override
  State<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  @override
  void initState() {
    super.initState();
    OmniNoteService.instance.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final notes = OmniNoteService.instance.notes;
    return Scaffold(
      drawer: const MainMenuDrawer(),
      appBar: AppBar(title: const Text('Journal')),
      body: notes.isEmpty
          ? const Center(child: Text('No notes yet.'))
          : ListView.builder(
              itemCount: notes.length,
              itemBuilder: (_, i) {
                final n = notes[i];
                final proj = n.projectId != null
                    ? ProjectService.instance.getById(n.projectId!)
                    : null;
                return Card(
                  child: ListTile(
                    title:
                        Text(n.title.isEmpty ? '(No Title)' : n.title),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          n.content,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (proj != null)
                          Text(
                            'Project: ${proj.title}',
                            style: const TextStyle(
                                fontSize: 12,
                                fontStyle: FontStyle.italic),
                          ),
                        Text(
                          DateFormat.yMMMd()
                              .add_jm()
                              .format(n.lastUpdated),
                          style: const TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                    onTap: () => Navigator.of(context)
                        .push(MaterialPageRoute(
                            builder: (_) =>
                                NoteDetailPage(omniNote: n)))
                        .then((_) => setState(() {})),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context)
            .push(MaterialPageRoute(
                builder: (_) => const NoteDetailPage()))
            .then((_) => setState(() {})),
        child: const Icon(Icons.add),
      ),
    );
  }
}
