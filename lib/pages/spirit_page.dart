// File: lib/pages/spirit_page.dart

import 'package:flutter/foundation.dart';  // ← for describeEnum
import 'package:flutter/material.dart';

import '../models/zone_theme.dart';
import '../models/spirit.dart';
import '../services/spirit_service.dart';

class SpiritPage extends StatelessWidget {
  const SpiritPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final svc = SpiritService.instance;
    return Scaffold(
      appBar: AppBar(title: const Text('Realm Spirits')),
      body: ListView(
        children: ZoneTheme.values.map((realm) {
          final spirits = svc.forRealm(realm);
          final primary = svc.getPrimary(realm);
          return ExpansionTile(
            leading: _iconFor(realm),
            title: Text(describeEnum(realm)),
            subtitle: Text('Master: ${primary?.name ?? '—'}'),
            children: spirits.map((s) => ListTile(
              leading: Icon(
                s.isPrimary
                  ? Icons.star
                  : s.isNPC
                    ? Icons.emoji_objects
                    : Icons.local_florist
              ),
              title: Text(s.name),
              subtitle: Text(s.description),
            )).toList(),
          );
        }).toList(),
      ),
    );
  }

  Icon _iconFor(ZoneTheme realm) {
    switch (realm) {
      case ZoneTheme.Air:
        return const Icon(Icons.cloud);
      case ZoneTheme.Earth:
        return const Icon(Icons.grass);
      case ZoneTheme.Fire:
        return const Icon(Icons.local_fire_department);
      case ZoneTheme.Water:
        return const Icon(Icons.water);
      case ZoneTheme.Void:
        return const Icon(Icons.account_tree);
    }
    // Fallback in case a new enum value is added later:
    return const Icon(Icons.help);
  }
}
