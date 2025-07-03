// File: lib/pages/spirit_page.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/zone_theme.dart';
import '../models/spirit.dart';
import '../services/spirit_service.dart';
import '../services/deck_service.dart';
import '../widgets/help_button.dart';
import '../widgets/main_menu_drawer.dart';

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
    final svc = SpiritService.instance;

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
        ],
      ),
      body: ListView(
        children: ZoneTheme.values.map((realm) {
          // find all spirits in this realm
          final spirits = svc.getByRealm(realm);
          // find the master spirit(s) in this realm
          final masters = svc.getPrimaries().where((s) => s.realm == realm);
          final primary = masters.isNotEmpty ? masters.first : null;

          return ExpansionTile(
            leading: _iconFor(realm),
            title: Text(describeEnum(realm)),
            subtitle: Text('Master: ${primary?.name ?? '—'}'),
            children: spirits.map((s) => _SpiritTile(spirit: s)).toList(),
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

class _SpiritTile extends StatelessWidget {
  final Spirit spirit;
  const _SpiritTile({required this.spirit, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final icon = spirit.isPrimary
        ? Icons.star
        : spirit.isNPC
            ? Icons.emoji_objects
            : Icons.local_florist;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: Icon(icon, color: Colors.deepPurple),
        title: Text(spirit.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(spirit.mythos),
        isThreeLine: true,
        trailing: spirit.isCollectible && !spirit.isPrimary && !spirit.isNPC
            ? ElevatedButton(
                child: const Text('Collect'),
                onPressed: () async {
                  final drawn = await DeckService.instance.draw(spirit);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(
                      drawn != null
                        ? 'Collected ${spirit.name}!'
                        : '${spirit.name} is already in your deck.',
                    )),
                  );
                },
              )
            : null,
        onTap: () => showDialog<void>(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(spirit.name),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Archetype: ${spirit.archetype}'),
                const SizedBox(height: 8),
                Text('Purpose: ${spirit.purpose}'),
                const SizedBox(height: 4),
                Text('Use in App: ${spirit.useInApp}'),
                const SizedBox(height: 4),
                Text('XP Value: ${spirit.xpValue}'),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
            ],
          ),
        ),
      ),
    );
  }
}
