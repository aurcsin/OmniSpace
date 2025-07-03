// File: lib/pages/trash_page.dart

import 'package:flutter/material.dart';

import '../models/omni_note.dart';
import '../models/tracker.dart';
import '../models/zone_theme.dart';
import '../services/omni_note_service.dart';
import '../services/tracker_service.dart';
import '../services/spirit_service.dart';
import '../services/deck_service.dart';
import '../widgets/help_button.dart';
import '../widgets/main_menu_drawer.dart';
import 'multi_pane_editor_page.dart';
import 'tracker_view_page.dart';

class TrashPage extends StatefulWidget {
  const TrashPage({Key? key}) : super(key: key);

  @override
  State<TrashPage> createState() => _TrashPageState();
}

class _TrashPageState extends State<TrashPage> {
  late List<OmniNote> _trashedNotes;
  late List<Tracker> _trashedTrackers;

  final _noteSvc   = OmniNoteService.instance;
  final _trackSvc  = TrackerService.instance;
  final _spiritSvc = SpiritService.instance;
  final _deckSvc   = DeckService.instance;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    _trashedNotes = _noteSvc.trashedNotes;
    _trashedTrackers = _trackSvc.all.where((t) => t.isTrashed).toList();
    setState(() {});
  }

  Future<void> _drawVoidSpirit() async {
    final s = await _deckSvc.drawFromRealm(ZoneTheme.Void);
    final msg = s != null
        ? 'Drew ${s.name}!'
        : 'All Void spirits already in your deck.';
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Master Void spirit
    final primaries = _spiritSvc.getPrimaries().where((s) => s.realm == ZoneTheme.Void);
    final master = primaries.isNotEmpty ? primaries.first : null;
    // Collectible Void spirits
    final reps = _spiritSvc.getCollectibles().where((s) => s.realm == ZoneTheme.Void).toList();

    return Scaffold(
      drawer: const MainMenuDrawer(),
      appBar: AppBar(
        title: const Text('Trash'),
        actions: [
          HelpButton(
            helpTitle: 'Trash Help',
            helpText: '''
• Restore or permanently delete notes and trackers.  
• You can also draw Void spirits here to refill your deck.''',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(8),
        children: [
          if (master != null) ...[
            // Void realm master spirit
            Card(
              color: Colors.grey.shade200,
              child: ListTile(
                leading: Icon(master.realm.icon, size: 36, color: Colors.grey),
                title: Text(master.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(master.purpose),
              ),
            ),
            const SizedBox(height: 8),
            // Representative Void spirits
            Wrap(
              spacing: 8,
              children: reps.map((s) {
                final inDeck = _deckSvc.deck.spiritIds.contains(s.id);
                return ActionChip(
                  avatar: Icon(s.realm.icon, size: 20, color: inDeck ? Colors.grey : Colors.white),
                  label: Text(s.name),
                  backgroundColor: inDeck ? Colors.grey.shade300 : Colors.black54,
                  labelStyle: TextStyle(color: inDeck ? Colors.black : Colors.white),
                  onPressed: inDeck ? null : () async {
                    await _deckSvc.draw(s);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Added ${s.name} to deck!')),
                      );
                    }
                  },
                );
              }).toList(),
            ),
            const Divider(height: 32),
          ],

          // --- Trashed Notes ---
          if (_trashedNotes.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('Notes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            ..._trashedNotes.map((note) {
              return ListTile(
                leading: const Icon(Icons.note, color: Colors.grey),
                title: Text(note.title.isNotEmpty ? note.title : '(No Title)'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.restore),
                      tooltip: 'Restore Note',
                      onPressed: () async {
                        await _noteSvc.restoreNote(note.id);
                        _refresh();
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_forever),
                      tooltip: 'Delete Permanently',
                      onPressed: () async {
                        await _noteSvc.deleteNote(note.id);
                        _refresh();
                      },
                    ),
                  ],
                ),
                onTap: () => Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => MultiPaneEditorPage(note)))
                    .then((_) => _refresh()),
              );
            }).toList(),
            const Divider(height: 32),
          ],

          // --- Trashed Trackers ---
          if (_trashedTrackers.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('Trackers', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            ..._trashedTrackers.map((tr) {
              return ListTile(
                leading: const Icon(Icons.auto_graph, color: Colors.grey),
                title: Text(tr.title.isNotEmpty ? tr.title : '(No Title)'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.restore),
                      tooltip: 'Restore Tracker',
                      onPressed: () async {
                        await _trackSvc.restoreTracker(tr.id);
                        _refresh();
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_forever),
                      tooltip: 'Delete Permanently',
                      onPressed: () async {
                        await _trackSvc.deleteTracker(tr.id);
                        _refresh();
                      },
                    ),
                  ],
                ),
                onTap: () => Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => TrackerViewPage(tracker: tr)))
                    .then((_) => _refresh()),
              );
            }).toList(),
          ],

          if (_trashedNotes.isEmpty && _trashedTrackers.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 32),
              child: Center(child: Text('Trash is empty.', style: TextStyle(color: Colors.grey))),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.filter_alt),
        label: const Text('Draw Void Spirit'),
        onPressed: _drawVoidSpirit,
      ),
    );
  }
}
