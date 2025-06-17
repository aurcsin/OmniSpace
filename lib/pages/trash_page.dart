// File: lib/pages/trash_page.dart

import 'package:flutter/material.dart';

import '../models/omni_note.dart';
import '../models/tracker.dart';
import '../services/omni_note_service.dart';
import '../services/tracker_service.dart';
import '../widgets/main_menu_drawer.dart';

class TrashPage extends StatefulWidget {
  const TrashPage({super.key});

  @override
  State<TrashPage> createState() => _TrashPageState();
}

class _TrashPageState extends State<TrashPage> {
  late List<OmniNote> _trashedNotes;
  late List<Tracker> _trashedTrackers;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _trashedNotes = OmniNoteService.instance.trashedNotes;
    _trashedTrackers = TrackerService.instance.trashedTrackers;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MainMenuDrawer(),
      appBar: AppBar(title: const Text('Trash')),
      body: ListView(
        children: [
          // --- Trashed Notes ---
          if (_trashedNotes.isNotEmpty) ...[
            const Divider(),
            const ListTile(title: Text('Notes')),
          ],
          for (var note in _trashedNotes)
            ListTile(
              title: Text(
                note.title.isNotEmpty ? note.title : '(No Title)',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.restore),
                    tooltip: 'Restore Note',
                    onPressed: () async {
                      await OmniNoteService.instance
                          .restoreNotes([note.id]);
                      _reload();
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_forever),
                    tooltip: 'Delete Permanently',
                    onPressed: () async {
                      await OmniNoteService.instance
                          .deletePermanent([note.id]);
                      _reload();
                    },
                  ),
                ],
              ),
            ),

          // --- Trashed Trackers ---
          if (_trashedTrackers.isNotEmpty) ...[
            const Divider(),
            const ListTile(title: Text('Trackers')),
          ],
          for (var tr in _trashedTrackers)
            ListTile(
              title: Text(
                tr.title.isNotEmpty ? tr.title : '(No Title)',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.restore),
                    tooltip: 'Restore Tracker',
                    onPressed: () async {
                      await TrackerService.instance
                          .restoreTrackers([tr.id]);
                      _reload();
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_forever),
                    tooltip: 'Delete Permanently',
                    onPressed: () async {
                      await TrackerService.instance
                          .deletePermanent([tr.id]);
                      _reload();
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
