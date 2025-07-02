// File: lib/pages/garden_forest_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/omni_note.dart';
import '../models/zone_theme.dart';
import '../models/spirit.dart';
import '../services/omni_note_service.dart';
import '../services/spirit_service.dart';
import '../services/deck_service.dart';
import 'multi_pane_editor_page.dart';

class GardenForestPage extends StatefulWidget {
  const GardenForestPage({Key? key}) : super(key: key);

  @override
  State<GardenForestPage> createState() => _GardenForestPageState();
}

class _GardenForestPageState extends State<GardenForestPage> {
  final noteSvc   = OmniNoteService.instance;
  final spiritSvc = SpiritService.instance;
  final deckSvc   = DeckService.instance;

  Future<void> _drawRealmSpirit() async {
    final s = await deckSvc.drawFromRealm(ZoneTheme.Earth);
    final msg = s != null
        ? 'Drew ${s.name}!'
        : 'All Garden spirits already in your deck.';
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final master = spiritSvc.getPrimary(ZoneTheme.Earth)!;
    final reps = spiritSvc
        .forRealm(ZoneTheme.Earth)
        .where((s) => !s.isPrimary)
        .toList();

    // Synchronously fetch and filter notes
    final entries = noteSvc.notes
        .where((n) =>
            n.zone == ZoneTheme.Earth && !n.isArchived && !n.isTrashed)
        .toList()
      ..sort((a, b) => b.lastUpdated.compareTo(a.lastUpdated));

    return Scaffold(
      appBar: AppBar(title: const Text('Garden • Forest')),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            // Master Spirit
            Card(
              color: Colors.green.shade50,
              child: ListTile(
                leading: Icon(master.realm.icon,
                    size: 40, color: Colors.green),
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
                      inDeck ? Colors.grey.shade300 : Colors.greenAccent,
                  labelStyle: TextStyle(
                      color: inDeck ? Colors.black : Colors.white),
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

            // Grid of entries
            Expanded(
              child: entries.isEmpty
                  ? const Center(child: Text('No Garden notes yet.'))
                  : GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: entries.length,
                      itemBuilder: (ctx, i) {
                        final n = entries[i];
                        return GestureDetector(
                          onTap: () => Navigator.of(context)
                              .push(MaterialPageRoute(
                                  builder: (_) => MultiPaneEditorPage(n)))
                              .then((_) => setState(() {})),
                          child: Card(
                            child: Center(
                              child: Text(
                                n.title.isEmpty ? '(No title)' : n.title,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.filter_alt),
        label: const Text('Draw Garden Spirit'),
        onPressed: _drawRealmSpirit,
      ),
    );
  }
}
