// File: lib/pages/spirit_page.dart

import 'package:flutter/material.dart';

import '../models/zone_theme.dart';
import '../models/spirit.dart';
import '../services/spirit_service.dart';
import '../services/deck_service.dart';            // for Collect action
import '../widgets/main_menu_drawer.dart';

class SpiritPage extends StatelessWidget {
  const SpiritPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final svc = SpiritService.instance;
    return Scaffold(
      drawer: const MainMenuDrawer(),
      appBar: AppBar(title: const Text('Realm Spirits')),
      body: ListView(
        children: ZoneTheme.values.map((realm) {
          final spirits = svc.forRealm(realm);
          final primary = svc.getPrimary(realm)!;
          return ExpansionTile(
            leading: Icon(_iconFor(realm), color: Colors.deepPurple),
            title: Text('${realm.name} Realm'),
            subtitle: Text('Master: ${primary.name}'),
            children: spirits.map((s) => _SpiritCard(spirit: s)).toList(),
          );
        }).toList(),
      ),
    );
  }

  IconData _iconFor(ZoneTheme realm) {
    switch (realm) {
      case ZoneTheme.Air:
        return Icons.cloud;
      case ZoneTheme.Earth:
        return Icons.grass;
      case ZoneTheme.Fire:
        return Icons.local_fire_department;
      case ZoneTheme.Water:
        return Icons.water;
      case ZoneTheme.Void:
        return Icons.nights_stay;
      case ZoneTheme.Fusion:
        return Icons.bubble_chart;
    }
  }
}

class _SpiritCard extends StatelessWidget {
  final Spirit spirit;
  const _SpiritCard({required this.spirit, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(_iconFor(spirit.realm), size: 32, color: Colors.deepPurple),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                spirit.name,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Chip(label: Text(spirit.realm.name)),
          ]),
          const SizedBox(height: 8),
          const Divider(),
          Text('• Mythos: ${spirit.mythos}'),
          const SizedBox(height: 4),
          Text('• Purpose: ${spirit.purpose}'),
          const SizedBox(height: 4),
          Text('• Use: ${spirit.useInApp}'),
          const SizedBox(height: 8),
          if (spirit.isPrimary)
            Align(
              alignment: Alignment.centerRight,
              child: Chip(
                label: const Text('Master Spirit'),
                backgroundColor: Colors.yellow.shade100,
              ),
            )
          else if (spirit.isNPC)
            Align(
              alignment: Alignment.centerRight,
              child: Chip(label: const Text('Herald Spirit')),
            )
          else if (spirit.isCollectible)
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Collect'),
                onPressed: () {
                  DeckService.instance.draw(spirit);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Collected ${spirit.name}!')),
                  );
                },
              ),
            ),
        ]),
      ),
    );
  }

  IconData _iconFor(ZoneTheme realm) {
    switch (realm) {
      case ZoneTheme.Air:
        return Icons.cloud;
      case ZoneTheme.Earth:
        return Icons.grass;
      case ZoneTheme.Fire:
        return Icons.local_fire_department;
      case ZoneTheme.Water:
        return Icons.water;
      case ZoneTheme.Void:
        return Icons.nights_stay;
      case ZoneTheme.Fusion:
        return Icons.bubble_chart;
    }
  }
}
