import 'package:flutter/material.dart';

import '../models/tracker.dart';
import '../models/tracker_type.dart';
import '../models/spirit.dart';
import '../models/zone_theme.dart';
import '../services/tracker_service.dart';
import '../services/spirit_service.dart';
import '../services/deck_service.dart';
import 'tracker_forge_page.dart';
import 'tracker_view_page.dart';

class WorkshopForgePage extends StatefulWidget {
  const WorkshopForgePage({Key? key}) : super(key: key);
  @override
  State<WorkshopForgePage> createState() => _WorkshopForgePageState();
}

class _WorkshopForgePageState extends State<WorkshopForgePage> {
  final svc       = TrackerService.instance;
  final spiritSvc = SpiritService.instance;
  final deckSvc   = DeckService.instance;

  Future<void> _drawRealmSpirit() async {
    final s = await deckSvc.drawFromRealm(ZoneTheme.Fire);
    final msg = s != null
      ? 'Drew ${s.name}!'
      : 'All Forge spirits already in deck.';
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final master = spiritSvc.getPrimary(ZoneTheme.Fire)!;
    final reps   = spiritSvc.forRealm(ZoneTheme.Fire).where((s) => !s.isPrimary).toList();
    final all    = svc.all;

    // group by type
    final byType = { for (var t in TrackerType.values) t: all.where((tr)=>tr.type==t).toList() };

    return Scaffold(
      appBar: AppBar(title: const Text('Workshop • Forge')),
      body: ListView(
        padding: const EdgeInsets.all(8),
        children: [
          // Master Spirit
          Card(
            color: Colors.red.shade50,
            child: ListTile(
              leading: Icon(master.realm.icon, size: 40, color: Colors.red),
              title: Text(master.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(master.description),
            ),
          ),

          // Other spirits
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: reps.map((s) {
              final inDeck = deckSvc.deck.spiritIds.contains(s.id);
              return ActionChip(
                avatar: Icon(s.realm.icon, size: 20, color: inDeck ? Colors.grey : Colors.white),
                label: Text(s.name),
                backgroundColor: inDeck ? Colors.grey.shade300 : Colors.redAccent,
                labelStyle: TextStyle(color: inDeck ? Colors.black : Colors.white),
                onPressed: inDeck ? null : () async {
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
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => TrackerViewPage(tracker: tr)),
                ).then((_) => setState(() {})),
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
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const TrackerForgePage()),
            ).then((_) => setState(() {})),
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
