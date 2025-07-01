// File: lib/pages/account_page.dart

import 'package:flutter/material.dart';

import '../models/zone_theme.dart';
import '../services/omni_note_service.dart';
import '../services/tracker_service.dart';
import '../widgets/main_menu_drawer.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({Key? key}) : super(key: key);

  /// Compute XP as number of non-trashed notes in that realm.
  int _xpForRealm(ZoneTheme realm) {
    return OmniNoteService.instance.notes
        .where((n) => n.zone == realm && !n.isTrashed)
        .length;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      drawer: const MainMenuDrawer(),
      appBar: AppBar(title: const Text('Account')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 40,
                backgroundColor: Theme.of(context).primaryColor,
                child: const Icon(Icons.person, size: 48, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text('Your Profile', style: textTheme.titleLarge),
            ),
            const SizedBox(height: 24),
            Text('Elemental Experience',
                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...ZoneTheme.values.map((realm) {
              final xp = _xpForRealm(realm);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Icon(realm.icon, color: Colors.deepPurple),
                    const SizedBox(width: 12),
                    Expanded(child: Text(realm.displayName)),
                    Text('$xp XP'),
                  ],
                ),
              );
            }).toList(),
            const SizedBox(height: 24),
            Text('Archetype Alignment',
                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            // Placeholder: derive real archetype from your data model
            const Text('Current archetype: Healer'),
            const Spacer(),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.logout),
                label: const Text('Log Out'),
                onPressed: () {
                  // TODO: hook into your auth/logout flow
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
