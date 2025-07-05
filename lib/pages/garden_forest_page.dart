// lib/pages/garden_forest_page.dart

import 'package:flutter/material.dart';

import 'package:omnispace/models/zone_theme.dart';
import 'package:omnispace/models/spirit.dart';
import 'package:omnispace/services/omni_note_service.dart';
import 'package:omnispace/services/spirit_service.dart';
import 'package:omnispace/services/deck_service.dart';
import 'package:omnispace/widgets/help_button.dart';
import 'package:omnispace/widgets/main_menu_drawer.dart';
import 'package:omnispace/pages/multi_pane_editor_page.dart';

class GardenForestPage extends StatefulWidget {
  const GardenForestPage({Key? key}) : super(key: key);

  @override
  State<GardenForestPage> createState() => _GardenForestPageState();
}

class _GardenForestPageState extends State<GardenForestPage> {
  final noteSvc   = OmniNoteService.instance;
  final spiritSvc = SpiritService.instance;
  final deckSvc   = DeckService.instance;

  /// Map moods to flower colors
  static const Map<String, Color> _moodColor = {
    'Calm':        Colors.blue,
    'Energetic':   Colors.red,
    'Focused':     Colors.yellow,
    'Grounded':    Colors.brown,
    'Curious':     Colors.purple,
    'Fusion Flow': Colors.grey,
  };

  Future<void> _drawRealmSpirit() async {
    final s = await deckSvc.drawFromRealm(ZoneTheme.Earth);
    final msg = s != null
      ? 'Drew ${s.name}!'
      : 'All Forest spirits are already in your deck.';
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    // Safe master lookup without firstWhere(null)
    final List<Spirit> primaries = spiritSvc
        .getPrimaries()
        .where((s) => s.realm == ZoneTheme.Earth)
        .toList();
    final Spirit? master = primaries.isNotEmpty ? primaries.first : null;

    // All collectible spirits for this realm
    final List<Spirit> reps = spiritSvc
        .getCollectibles()
        .where((s) => s.realm == ZoneTheme.Earth)
        .toList();

    // All relevant notes
    final entries = noteSvc.notes
        .where((n) => n.zone == ZoneTheme.Earth && !n.isArchived && !n.isTrashed)
        .toList();

    return Scaffold(
      drawer: const MainMenuDrawer(),
      appBar: AppBar(
        title: const Text('Garden • Forest'),
        actions: [
          HelpButton(
            helpTitle: 'Forest Garden Help',
            helpText: '''
• The master spirit guides this realm.  
• Collect spirits below to grow your deck.  
• Your journal entries appear as flowers.  
• Flower color reflects the note’s mood.''',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            // Master Spirit (if any)
            if (master != null)
              Card(
                color: Colors.green.shade50,
                child: ListTile(
                  leading: Icon(master.realm.icon, size: 40, color: Colors.green),
                  title: Text(master.name,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(master.purpose),
                ),
              ),

            const SizedBox(height: 8),

            // Representative (collectible) spirits
            Wrap(
              spacing: 8,
              children: reps.map((s) {
                final bool inDeck = deckSvc.deck.any((d) => d.id == s.id);
                return ActionChip(
                  avatar: Icon(
                    s.realm.icon,
                    size: 20,
                    color: inDeck ? Colors.grey : Colors.white,
                  ),
                  label: Text(s.name),
                  backgroundColor:
                      inDeck ? Colors.grey.shade300 : Colors.greenAccent,
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

            // Grid of journal entries as flowers
            Expanded(
              child: entries.isEmpty
                  ? const Center(child: Text('No Forest notes yet.'))
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
                        final Color color = _moodColor[n.mood ?? ''] ?? Colors.green;
                        return GestureDetector(
                          onTap: () => Navigator.of(context)
                              .push(MaterialPageRoute(
                                  builder: (_) => MultiPaneEditorPage(n)))
                              .then((_) => setState(() {})),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.local_florist,
                                  size: 48, color: color),
                              const SizedBox(height: 4),
                              Text(
                                n.title.isEmpty ? '(No title)' : n.title,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
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
        label: const Text('Draw Forest Spirit'),
        onPressed: _drawRealmSpirit,
      ),
    );
  }
}
