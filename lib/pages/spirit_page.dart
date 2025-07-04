// lib/pages/spirit_page.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:omnispace/models/zone_theme.dart';
import 'package:omnispace/models/spirit.dart';
import 'package:omnispace/services/spirit_service.dart';
import 'package:omnispace/services/deck_service.dart';
import 'package:omnispace/widgets/help_button.dart';
import 'package:omnispace/widgets/main_menu_drawer.dart';

class SpiritPage extends StatelessWidget {
  const SpiritPage({Key? key}) : super(key: key);

  void _showHelp(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('About Realm Spirits'),
        content: const Text(
          'In OmniSpace, each Elemental Realm is guided by a Master Spirit, '
          'supported by Heralds, and populated by Collectible spirits. '
          'Masters offer wisdom, Heralds herald change, and Collectibles '
          'reflect the emergent life of their realm. You’ll gather spirits '
          'to your deck by exploring realms and fulfilling tasks.\n\n'
          'Tap “Collect” to add a spirit to your deck. '
          'Use the Deck page to review and manage your collection.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Got it')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final spiritSvc = SpiritService.instance;
    final deckSvc = DeckService.instance;

    return Scaffold(
      drawer: const MainMenuDrawer(),
      appBar: AppBar(
        title: const Text('Realm Spirits'),
        actions: [
          HelpButton(
            helpTitle: 'Realm Spirits Help',
            helpText: '''
• Each realm has a Master spirit and Collectibles.  
• Masters guide you; Collectibles you can gather.  
• Tap “Collect” to add to your deck.  
• View your collection on the Deck page.''',
          ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: 'Help',
            onPressed: () => _showHelp(context),
          ),
        ],
      ),
      body: ListView(
        children: ZoneTheme.values.map((realm) {
          // All collectible spirits in this realm
          final spirits = spiritSvc
              .getCollectibles()
              .where((s) => s.realm == realm)
              .toList();
          // Master spirit for this realm
          final masters = spiritSvc
              .getPrimaries()
              .where((s) => s.realm == realm);
          final primary = masters.isNotEmpty ? masters.first : null;

          return ExpansionTile(
            leading: _iconFor(realm),
            title: Text(describeEnum(realm)),
            subtitle: Text('Master: ${primary?.name ?? '—'}'),
            children: spirits.map((s) {
              // Check deck membership correctly
              final inDeck = deckSvc.deck.any((d) => d.id == s.id);
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: Icon(
                    s.isPrimary ? Icons.star
                      : s.isNPC ? Icons.emoji_objects
                      : Icons.local_florist,
                    color: Colors.deepPurple,
                  ),
                  title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(s.mythos),
                  isThreeLine: true,
                  trailing: s.isCollectible && !s.isPrimary && !s.isNPC
                      ? ElevatedButton(
                          onPressed: inDeck
                              ? null
                              : () async {
                                  final collected = await deckSvc.draw(s);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(
                                      collected != null
                                        ? 'Collected ${s.name}!'
                                        : '${s.name} was already in your deck.',
                                    )),
                                  );
                                },
                          child: Text(inDeck ? 'Collected' : 'Collect'),
                        )
                      : null,
                  onTap: () => showDialog<void>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text(s.name),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Archetype: ${s.archetype}'),
                          const SizedBox(height: 8),
                          Text('Purpose: ${s.purpose}'),
                          const SizedBox(height: 4),
                          Text('Use in App: ${s.useInApp}'),
                          const SizedBox(height: 4),
                          Text('XP Value: ${s.xpValue}'),
                        ],
                      ),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }

  Icon _iconFor(ZoneTheme realm) {
    switch (realm) {
      case ZoneTheme.Air:
        return const Icon(Icons.cloud, color: Colors.lightBlue);
      case ZoneTheme.Earth:
        return const Icon(Icons.grass, color: Colors.green);
      case ZoneTheme.Fire:
        return const Icon(Icons.local_fire_department, color: Colors.redAccent);
      case ZoneTheme.Water:
        return const Icon(Icons.water, color: Colors.blueAccent);
      case ZoneTheme.Void:
        return const Icon(Icons.nights_stay, color: Colors.grey);
      case ZoneTheme.Fusion:
        return const Icon(Icons.bubble_chart, color: Colors.purpleAccent);
    }
  }
}
