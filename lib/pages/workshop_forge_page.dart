// lib/pages/workshop_forge_page.dart

import 'package:flutter/material.dart';

import '../models/tracker_type.dart';
import '../models/zone_theme.dart';
import '../models/spirit.dart';
import '../services/tracker_service.dart';
import '../services/spirit_service.dart';
import '../services/deck_service.dart';
import '../widgets/help_button.dart';
import '../widgets/main_menu_drawer.dart';
import 'tracker_forge_page.dart';
import 'tracker_view_page.dart';

class WorkshopForgePage extends StatefulWidget {
  const WorkshopForgePage({Key? key}) : super(key: key);
  @override
  State<WorkshopForgePage> createState() => _WorkshopForgePageState();
}

class _WorkshopForgePageState extends State<WorkshopForgePage> {
  final _trackSvc  = TrackerService.instance;
  final _spiritSvc = SpiritService.instance;
  final _deckSvc   = DeckService.instance;

  Future<void> _drawRealmSpirit() async {
    final s = await _deckSvc.drawFromRealm(ZoneTheme.Fire);
    final msg = s != null
      ? 'Drew ${s.name}!'
      : 'All Forge spirits already in your deck.';
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    // Master Fire spirit
    final primaries = _spiritSvc
        .getPrimaries()
        .where((s) => s.realm == ZoneTheme.Fire)
        .toList();
    final Spirit? master = primaries.isNotEmpty ? primaries.first : null;

    // Collectible Fire spirits
    final reps = _spiritSvc.getCollectibles()
        .where((s) => s.realm == ZoneTheme.Fire && !s.isPrimary)
        .toList();

    // All trackers
    final all = _trackSvc.all;
    // Group trackers by type
    final byType = {
      for (var t in TrackerType.values)
        t: all.where((tr) => tr.type == t).toList()
    };

    return Scaffold(
      drawer: const MainMenuDrawer(),
      appBar: AppBar(
        title: const Text('Workshop • Forge'),
        actions: [
          HelpButton(
            helpTitle: 'Workshop Forge Help',
            helpText: '''
• The Forge realm is guided by Fire spirits.  
• Your master guardian appears at the top.  
• Collect other spirits below.  
• Trackers are organized by type under.''',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(8),
        children: [
          if (master != null) ...[
            // Master Spirit
            Card(
              color: Colors.red.shade50,
              child: ListTile(
                leading: Icon(master.realm.icon, size: 40, color: Colors.red),
                title: Text(master.name,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(master.purpose),
              ),
            ),
            const SizedBox(height: 8),
            // Other spirits
            Wrap(
              spacing: 8,
              children: reps.map((s) {
                // Check deck membership by spirit ID
                final inDeck = _deckSvc.deck.any((d) => d.id == s.id);
                return ActionChip(
                  avatar: Icon(
                    s.realm.icon,
                    size: 20,
                    color: inDeck ? Colors.grey : Colors.white,
                  ),
                  label: Text(s.name),
                  backgroundColor:
                      inDeck ? Colors.grey.shade300 : Colors.redAccent,
                  labelStyle:
                      TextStyle(color: inDeck ? Colors.black : Colors.white),
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
          ],

          // Trackers by type
          for (var type in TrackerType.values) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                type.name.toUpperCase(),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            if (byType[type]!.isEmpty)
              const Text('No items here.')
            else
              ...byType[type]!.map((tr) => ListTile(
                title: Text(tr.title),
                onTap: () => Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => TrackerViewPage(tracker: tr)))
                    .then((_) => setState(() {})),
              )),
          ],
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            heroTag: 'add_tracker',
            icon: const Icon(Icons.add),
            label: const Text('New Tracker'),
            onPressed: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const TrackerForgePage()))
                .then((_) => setState(() {})),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.extended(
            heroTag: 'draw_fire',
            icon: const Icon(Icons.filter_alt),
            label: const Text('Draw Forge Spirit'),
            onPressed: _drawRealmSpirit,
          ),
        ],
      ),
    );
  }
}
