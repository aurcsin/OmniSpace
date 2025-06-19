// File: lib/pages/trash_page.dart

import 'package:flutter/material.dart';

import '../models/omni_note.dart';
import '../models/tracker.dart';
import '../services/omni_note_service.dart';
import '../services/tracker_service.dart';
import '../widgets/main_menu_drawer.dart';

class TrashPage extends StatefulWidget {
  const TrashPage({Key? key}) : super(key: key);

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
    _trashedNotes    = OmniNoteService.instance.trashedNotes;
    _trashedTrackers = TrackerService.instance.trashed;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MainMenuDrawer(),
      appBar: AppBar(title: const Text('Trash')),
      body: ListView(
        children: [
          // --- Notes ---
          if (_trashedNotes.isNotEmpty) ...[
            const Divider(),
            const ListTile(title: Text('Notes')),
          ],
          for (var note in _trashedNotes)
            ListTile(
              title: Text(note.title.isNotEmpty ? note.title : '(No Title)'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Restore
                  IconButton(
                    icon: const Icon(Icons.restore),
                    tooltip: 'Restore Note',
                    onPressed: () async {
                      await OmniNoteService.instance.restoreNote(note.id);
                      _reload();
                    },
                  ),
                  // Delete permanently
                  IconButton(
                    icon: const Icon(Icons.delete_forever),
                    tooltip: 'Delete Permanently',
                    onPressed: () async {
                      await OmniNoteService.instance.deleteNote(note.id);
                      _reload();
                    },
                  ),
                ],
              ),
            ),

          // --- Trackers ---
          if (_trashedTrackers.isNotEmpty) ...[
            const Divider(),
            const ListTile(title: Text('Trackers')),
          ],
          for (var tr in _trashedTrackers)
            ListTile(
              title: Text(tr.title.isNotEmpty ? tr.title : '(No Title)'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Restore
                  IconButton(
                    icon: const Icon(Icons.restore),
                    tooltip: 'Restore Tracker',
                    onPressed: () async {
                      await TrackerService.instance.restoreTracker(tr.id);
                      _reload();
                    },
                  ),
                  // Delete permanently
                  IconButton(
                    icon: const Icon(Icons.delete_forever),
                    tooltip: 'Delete Permanently',
                    onPressed: () async {
                      await TrackerService.instance.deleteTracker(tr.id);
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
