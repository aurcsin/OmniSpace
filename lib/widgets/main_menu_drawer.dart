// File: lib/widgets/main_menu_drawer.dart

import 'package:flutter/material.dart';

class MainMenuDrawer extends StatelessWidget {
  const MainMenuDrawer({Key? key}) : super(key: key);

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('About OmniSpace'),
        content: SingleChildScrollView(
          child: Text(
            '''Welcome to OmniSpace!

• **Spirit World**  
  A living ecosystem of elemental spirits—Air, Earth, Fire, Water, Void & Fusion—that guide your journey.

• **Elemental Biomes**  
  Explore the Sky, Garden, Workshop, Studio & Root Cave. Each biome responds to your moods, notes, and quests.

• **Archetypes & XP**  
  Your actions earn XP. Spirits evolve, decks grow, and new biomes unlock as you journal, create decks, and tend your garden.

• **Decks & Artifacts**  
  Collect spirits and artifacts, build decks to shape your path, and fuse spirits for deeper insights.

Dive in, cultivate your inner world, and let OmniSpace be the canvas for your growth.''',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(child: Text('OmniSpace')),
          // … your existing menu items …
          ExpansionTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings & More'),
            children: [
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('About OmniSpace'),
                onTap: () {
                  Navigator.pop(context);
                  _showAboutDialog(context);
                },
              ),
              // … other settings entries …
            ],
          ),
        ],
      ),
    );
  }
}
