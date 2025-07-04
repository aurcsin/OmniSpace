// lib/pages/sky_space_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/zone_theme.dart';
import '../models/spirit.dart';
import '../services/omni_note_service.dart';
import '../services/spirit_service.dart';
import '../services/deck_service.dart';
import '../widgets/help_button.dart';
import '../widgets/main_menu_drawer.dart';
import 'multi_pane_editor_page.dart';

class SkySpacePage extends StatefulWidget {
  const SkySpacePage({Key? key}) : super(key: key);

  @override
  State<SkySpacePage> createState() => _SkySpacePageState();
}

class _SkySpacePageState extends State<SkySpacePage> {
  final noteSvc   = OmniNoteService.instance;
  final spiritSvc = SpiritService.instance;
  final deckSvc   = DeckService.instance;

  Future<void> _drawRealmSpirit() async {
    final s = await deckSvc.drawFromRealm(ZoneTheme.Air);
    final msg = s != null
      ? 'Drew ${s.name}!'
      : 'All Sky spirits already in your deck.';
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    // Master (primary) Air spirit, if any
    final primaries = spiritSvc
        .getPrimaries()
        .where((s) => s.realm == ZoneTheme.Air)
        .toList();
    final Spirit? master = primaries.isNotEmpty ? primaries.first : null;

    // Other Air spirits
    final reps = spiritSvc
        .getCollectibles()
        .where((s) => s.realm == ZoneTheme.Air)
        .toList();

    // Live Air notes
    final notes = noteSvc.notes
        .where((n) => n.zone == ZoneTheme.Air && !n.isArchived && !n.isTrashed)
        .toList()
      ..sort((a, b) => b.lastUpdated.compareTo(a.lastUpdated));

    return Scaffold(
      drawer: const MainMenuDrawer(),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
        title: const Text('Sky • Space'),
        centerTitle: true,
        actions: [
          HelpButton(
            helpTitle: 'Sky Space Help',
            helpText: '''
• The Sky realm is guided by Air spirits.  
• Your master guardian appears here.  
• Collect other spirits below.  
• Journal entries in this realm appear at the bottom.''',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(8),
        children: [
          // Master Spirit
          if (master != null)
            Card(
              color: Colors.lightBlue.shade50,
              child: ListTile(
                leading: Icon(master.realm.icon, size: 40, color: Colors.blue),
                title: Text(master.name,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(master.purpose),
              ),
            ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Other Spirits',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          // Collectible spirits
          Wrap(
            spacing: 8,
            children: reps.map((s) {
              // deckSvc.deck is List<Spirit>, so check membership by ID
              final inDeck = deckSvc.deck.any((d) => d.id == s.id);
              return ActionChip(
                avatar: Icon(
                  s.realm.icon,
                  size: 20,
                  color: inDeck ? Colors.grey : Colors.white,
                ),
                label: Text(s.name),
                backgroundColor:
                    inDeck ? Colors.grey.shade300 : Colors.deepPurple,
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

          // Journal entries
          if (notes.isEmpty)
            const Center(child: Text('No Sky notes yet.'))
          else
            ...notes.map((n) => ListTile(
                  title: Text(n.title.isEmpty ? '(No title)' : n.title),
                  subtitle:
                      Text(DateFormat.yMMMd().add_jm().format(n.lastUpdated)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => MultiPaneEditorPage(n)),
                  ),
                )),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.filter_alt),
        label: const Text('Draw Sky Spirit'),
        onPressed: _drawRealmSpirit,
      ),
    );
  }
}
