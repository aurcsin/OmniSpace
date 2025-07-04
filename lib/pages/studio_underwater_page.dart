// lib/pages/studio_underwater_page.dart

import 'package:flutter/material.dart';

import 'package:omnispace/models/omni_note.dart';
import 'package:omnispace/models/zone_theme.dart';
import 'package:omnispace/models/spirit.dart';              // <-- added
import 'package:omnispace/services/omni_note_service.dart';
import 'package:omnispace/services/spirit_service.dart';
import 'package:omnispace/services/deck_service.dart';
import 'package:omnispace/widgets/help_button.dart';
import 'package:omnispace/widgets/main_menu_drawer.dart';
import 'package:omnispace/pages/multi_pane_editor_page.dart';
import 'package:omnispace/pages/collections_page.dart';

class StudioUnderwaterPage extends StatefulWidget {
  const StudioUnderwaterPage({Key? key}) : super(key: key);
  @override
  State<StudioUnderwaterPage> createState() => _StudioUnderwaterPageState();
}

class _StudioUnderwaterPageState extends State<StudioUnderwaterPage> {
  final noteSvc   = OmniNoteService.instance;
  final spiritSvc = SpiritService.instance;
  final deckSvc   = DeckService.instance;

  Future<void> _drawRealmSpirit() async {
    final s = await deckSvc.drawFromRealm(ZoneTheme.Water);
    final msg = s != null
      ? 'Drew ${s.name}!'
      : 'All Studio spirits already in your deck.';
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    // Master spirit for Water realm
    final masters = spiritSvc.getPrimaries()
        .where((s) => s.realm == ZoneTheme.Water);
    final Spirit? master = masters.isNotEmpty ? masters.first : null;

    // Collectible spirits for Water realm (excluding primaries)
    final reps = spiritSvc.getCollectibles()
        .where((s) => s.realm == ZoneTheme.Water && !s.isPrimary)
        .toList();

    return Scaffold(
      drawer: const MainMenuDrawer(),
      appBar: AppBar(
        title: const Text('Studio • Underwater'),
        actions: [
          HelpButton(
            helpTitle: 'Studio Underwater Help',
            helpText: '''
• The Underwater realm is guided by a Water Spirit.  
• Collect other spirits below.  
• Notes with media appear in the media carousel.  
• Browse your collections from here.''',
          ),
        ],
      ),
      body: FutureBuilder<List<OmniNote>>(
        future: Future.value(noteSvc.notes),
        builder: (ctx, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final notes = snap.data!;
          final mediaNotes = notes.where((n) => n.attachments.isNotEmpty).toList();

          return ListView(
            padding: const EdgeInsets.all(8),
            children: [
              // Master Spirit
              if (master != null)
                Card(
                  color: Colors.blue.shade50,
                  child: ListTile(
                    leading: Icon(master.realm.icon, size: 40, color: Colors.blue),
                    title: Text(master.name,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(master.purpose),
                  ),
                ),

              const SizedBox(height: 8),
              // Other Spirits
              Wrap(
                spacing: 8,
                children: reps.map((s) {
                  final inDeck = deckSvc.deck.any((d) => d.id == s.id);
                  return ActionChip(
                    avatar: Icon(
                      s.realm.icon,
                      size: 20,
                      color: inDeck ? Colors.grey : Colors.white,
                    ),
                    label: Text(s.name),
                    backgroundColor:
                        inDeck ? Colors.grey.shade300 : Colors.blueAccent,
                    labelStyle:
                        TextStyle(color: inDeck ? Colors.black : Colors.white),
                    onPressed: inDeck
                        ? null
                        : () async {
                            await deckSvc.draw(s);
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
                child: Text('Notes with Media',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
              if (mediaNotes.isEmpty)
                const Center(child: Text('No media notes yet.'))
              else
                SizedBox(
                  height: 120,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: mediaNotes.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      final n = mediaNotes[i];
                      return GestureDetector(
                        onTap: () => Navigator.of(context)
                            .push(MaterialPageRoute(
                                builder: (_) => MultiPaneEditorPage(n)))
                            .then((_) => setState(() {})),
                        child: Container(
                          width: 100,
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.image, size: 48),
                        ),
                      );
                    },
                  ),
                ),

              const Divider(height: 32),
              ListTile(
                leading: const Icon(Icons.collections_bookmark),
                title: const Text('Browse Collections'),
                onTap: () => Navigator.of(context)
                    .push(MaterialPageRoute(
                        builder: (_) => const CollectionsPage()))
                    .then((_) => setState(() {})),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.filter_alt),
        label: const Text('Draw Studio Spirit'),
        onPressed: _drawRealmSpirit,
      ),
    );
  }
}
