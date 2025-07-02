// File: lib/pages/root_cave_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/omni_note.dart';
import '../models/zone_theme.dart';
import '../models/spirit.dart';
import '../services/omni_note_service.dart';
import '../services/spirit_service.dart';
import '../services/deck_service.dart';
import 'multi_pane_editor_page.dart';

class RootCavePage extends StatefulWidget {
  const RootCavePage({Key? key}) : super(key: key);

  @override
  State<RootCavePage> createState() => _RootCavePageState();
}

class _RootCavePageState extends State<RootCavePage> {
  final noteSvc   = OmniNoteService.instance;
  final spiritSvc = SpiritService.instance;
  final deckSvc   = DeckService.instance;

  Future<void> _drawRealmSpirit() async {
    final s = await deckSvc.drawFromRealm(ZoneTheme.Void);
    final msg = s != null
      ? 'Drew ${s.name}!'
      : 'All Cave spirits already in your deck.';
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final master = spiritSvc.getPrimary(ZoneTheme.Void)!;
    final reps = spiritSvc
        .forRealm(ZoneTheme.Void)
        .where((s) => !s.isPrimary)
        .toList();

    final notes = noteSvc.notes
        .where((n) =>
            n.zone == ZoneTheme.Void && !n.isArchived && !n.isTrashed)
        .toList()
      ..sort((a, b) => b.lastUpdated.compareTo(a.lastUpdated));

    return Scaffold(
      appBar: AppBar(title: const Text('Root Cave • Underground')),
      body: ListView(
        padding: const EdgeInsets.all(8),
        children: [
          // Master Spirit
          Card(
            color: Colors.brown.shade50,
            child: ListTile(
              leading: Icon(master.realm.icon, size: 40, color: Colors.brown),
              title: Text(master.name,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(master.mythos),
            ),
          ),
          const SizedBox(height: 8),

          // Representative spirits
          Wrap(
            spacing: 8,
            children: reps.map((s) {
              final inDeck = deckSvc.deck.spiritIds.contains(s.id);
              return ActionChip(
                avatar: Icon(s.realm.icon,
                    size: 20, color: inDeck ? Colors.grey : Colors.white),
                label: Text(s.name),
                backgroundColor:
                    inDeck ? Colors.grey.shade300 : Colors.brown,
                labelStyle:
                    TextStyle(color: inDeck ? Colors.black : Colors.white),
                onPressed: inDeck
                    ? null
                    : () async {
                        await deckSvc.draw(s);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Added ${s.name}!')),
                          );
                          setState(() {});
                        }
                      },
              );
            }).toList(),
          ),
          const Divider(height: 32),

          // Notes list
          if (notes.isEmpty)
            const Center(child: Text('No Cave notes yet.'))
          else
            ...notes.map((n) => ListTile(
                  title: Text(n.title.isEmpty ? '(No Title)' : n.title),
                  subtitle: Text(
                    DateFormat.yMMMd().add_jm().format(n.lastUpdated),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context)
                      .push(MaterialPageRoute(
                        builder: (_) => MultiPaneEditorPage(n),
                      ))
                      .then((_) => setState(() {})),
                )),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.filter_alt),
        label: const Text('Draw Cave Spirit'),
        onPressed: _drawRealmSpirit,
      ),
    );
  }
}
