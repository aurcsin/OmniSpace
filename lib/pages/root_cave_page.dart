// lib/pages/root_cave_page.dart

import 'package:flutter/material.dart';
import 'package:omnispace/models/omni_note.dart';
import 'package:omnispace/models/zone_theme.dart';
import 'package:omnispace/services/omni_note_service.dart';
import 'package:omnispace/services/spirit_service.dart';
import 'package:omnispace/services/deck_service.dart';
import 'package:omnispace/widgets/help_button.dart';
import 'package:omnispace/widgets/main_menu_drawer.dart';
import 'package:omnispace/pages/multi_pane_editor_page.dart';

class RootCavePage extends StatefulWidget {
  const RootCavePage({Key? key}) : super(key: key);

  @override
  State<RootCavePage> createState() => _RootCavePageState();
}

class _RootCavePageState extends State<RootCavePage> {
  final _noteSvc   = OmniNoteService.instance;
  final _spiritSvc = SpiritService.instance;
  final _deckSvc   = DeckService.instance;

  Future<void> _drawRealmSpirit() async {
    final s = await _deckSvc.drawFromRealm(ZoneTheme.Void);
    final msg = s != null
      ? 'Drew ${s.name}!'
      : 'All Root Cave spirits already in your deck.';
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    // Master spirit for Void realm
    final master = _spiritSvc
        .getPrimaries()
        .firstWhere((s) => s.realm == ZoneTheme.Void);
    // Collectible spirits for Void realm
    final reps = _spiritSvc
        .getCollectibles()
        .where((s) => s.realm == ZoneTheme.Void)
        .toList();

    return Scaffold(
      drawer: const MainMenuDrawer(),
      appBar: AppBar(
        title: const Text('Root Cave • Underground'),
        actions: [
          HelpButton(
            helpTitle: 'Cave Help',
            helpText: '''
• The Root Cave is the Void realm.  
• Master spirit guides you here.  
• Collect spirits to grow your deck.  
• Archived notes live below; restore from Trash.''',
          ),
        ],
      ),
      body: FutureBuilder<List<OmniNote>>(
        future: Future.value(_noteSvc.notes),
        builder: (ctx, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final all = snap.data!;
          final archived = all
              .where((n) => n.isArchived && !n.isTrashed)
              .toList();
          final trashed  = all.where((n) => n.isTrashed).toList();

          return ListView(
            padding: const EdgeInsets.all(8),
            children: [
              // Master Spirit
              Card(
                color: Colors.grey.shade200,
                child: ListTile(
                  leading: Icon(master.realm.icon, size: 40, color: Colors.grey),
                  title: Text(master.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(master.purpose),
                ),
              ),
              const SizedBox(height: 8),
              // Collectible spirits
              Wrap(
                spacing: 8,
                children: reps.map((s) {
                  final inDeck = _deckSvc.deck.any((d) => d.id == s.id);
                  return ActionChip(
                    avatar: Icon(s.realm.icon, size: 20, color: inDeck ? Colors.grey : Colors.white),
                    label: Text(s.name),
                    backgroundColor: inDeck ? Colors.grey.shade300 : Colors.black54,
                    labelStyle: TextStyle(color: inDeck ? Colors.black : Colors.white),
                    onPressed: inDeck
                        ? null
                        : () async {
                            await _deckSvc.draw(s);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Added ${s.name} to deck!')),
                              );
                              setState(() {});
                            }
                          },
                  );
                }).toList(),
              ),

              const Divider(height: 32),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('Archived Entries',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
              if (archived.isEmpty)
                const Center(child: Text('No archived notes.'))
              else
                ...archived.map((n) => ListTile(
                      title: Text(n.title.isEmpty ? '(No Title)' : n.title),
                      onTap: () => Navigator.of(context)
                          .push(MaterialPageRoute(builder: (_) => MultiPaneEditorPage(n)))
                          .then((_) => setState(() {})),
                    )),

              const Divider(height: 32),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('Trash',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
              if (trashed.isEmpty)
                const Center(child: Text('Trash is empty.'))
              else
                ...trashed.map((n) => ListTile(
                      title: Text(n.title.isEmpty ? '(No Title)' : n.title),
                      subtitle: const Text('Trashed'),
                      trailing: IconButton(
                        icon: const Icon(Icons.restore),
                        tooltip: 'Restore Note',
                        onPressed: () async {
                          await _noteSvc.setTrashed(n.id, false);
                          setState(() {});
                        },
                      ),
                      onTap: () => Navigator.of(context)
                          .push(MaterialPageRoute(builder: (_) => MultiPaneEditorPage(n)))
                          .then((_) => setState(() {})),
                    )),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.filter_alt),
        label: const Text('Draw Cave Spirit'),
        onPressed: _drawRealmSpirit,
      ),
    );
  }
}
