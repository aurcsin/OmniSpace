// File: lib/pages/deck_page.dart

import 'package:flutter/material.dart';

import '../models/zone_theme.dart';
import '../services/deck_service.dart';
import '../services/spirit_service.dart';
import '../widgets/main_menu_drawer.dart';
import '../widgets/help_button.dart';

class DeckPage extends StatefulWidget {
  const DeckPage({Key? key}) : super(key: key);

  @override
  State<DeckPage> createState() => _DeckPageState();
}

class _DeckPageState extends State<DeckPage> {
  late final deckSvc   = DeckService.instance;
  late final spiritSvc = SpiritService.instance;

  @override
  Widget build(BuildContext context) {
    final cards = deckSvc.cards;
    return Scaffold(
      drawer: const MainMenuDrawer(),
      appBar: AppBar(
        title: const Text('My Spirit Deck'),
        actions: [
          HelpButton(
            helpTitle: 'Deck Help',
            helpText: '''
• Your deck holds spirits you’ve collected.  
• Swipe a card to remove it.  
• “Draw Random” picks any new spirit.  
• “Draw by Realm” limits to that element.  
• Refresh resets your deck.''',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset Deck',
            onPressed: () async {
              await deckSvc.reset();
              setState(() {});
            },
          ),
        ],
      ),
      body: cards.isEmpty
          ? const Center(child: Text('Your deck is empty.'))
          : ListView.builder(
              itemCount: cards.length,
              itemBuilder: (context, i) {
                final s = cards[i];
                return Dismissible(
                  key: ValueKey(s.id),
                  background: Container(color: Colors.red),
                  onDismissed: (_) async {
                    await deckSvc.remove(s);
                    setState(() {});
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Removed ${s.name}')),
                    );
                  },
                  child: ListTile(
                    leading: Icon(
                      s.realm.icon,
                      color: s.isPrimary
                          ? Colors.amber
                          : s.isNPC
                              ? Colors.deepPurple
                              : Colors.teal,
                    ),
                    title: Text(s.name),
                    subtitle: Text(s.purpose),
                    trailing: Text(s.realm.displayName),
                  ),
                );
              },
            ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            heroTag: 'draw_random',
            icon: const Icon(Icons.shuffle),
            label: const Text('Draw Random'),
            onPressed: () async {
              final s = await deckSvc.drawRandomCollectible();
              if (s != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Drew ${s.name}!')),
                );
                setState(() {});
              }
            },
          ),
          const SizedBox(height: 8),
          FloatingActionButton.extended(
            heroTag: 'draw_by_realm',
            icon: const Icon(Icons.filter_alt),
            label: const Text('Draw by Realm'),
            onPressed: () => _showRealmSelector(),
          ),
        ],
      ),
    );
  }

  void _showRealmSelector() {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: ZoneTheme.values.map((realm) {
            return ListTile(
              leading: Icon(realm.icon, color: Colors.deepPurple),
              title: Text('Draw from ${realm.displayName}'),
              onTap: () async {
                Navigator.pop(context);
                final s = await deckSvc.drawFromRealm(realm);
                if (s != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Drew ${s.name}!')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('No more new spirits in ${realm.displayName}.')),
                  );
                }
                setState(() {});
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
