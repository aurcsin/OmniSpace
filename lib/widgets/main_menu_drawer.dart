// File: lib/widgets/main_menu_drawer.dart

import 'package:flutter/material.dart';

// Elemental pages
import '../pages/sky_space_page.dart';
import '../pages/garden_forest_page.dart';
import '../pages/workshop_forge_page.dart';
import '../pages/studio_underwater_page.dart';
import '../pages/root_cave_page.dart';           // now exports RootCavePage

// User logs
import '../pages/journal_page.dart';
import '../pages/omni_tracker_page.dart';
import '../pages/projects_page.dart';
import '../pages/calendar_overview_page.dart';   // only this file defines CalendarOverviewPage

// Spirits & Deck
import '../pages/spirit_page.dart';
import '../pages/deck_page.dart';

// Misc
import '../pages/collections_page.dart';
import '../pages/options_page.dart';
import '../pages/trash_page.dart';
import '../pages/account_page.dart';

class MainMenuDrawer extends StatelessWidget {
  const MainMenuDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(padding: EdgeInsets.zero, children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.deepPurple),
            child: Text(
              'OmniSpace',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),

          ExpansionTile(
            leading: const Icon(Icons.public, color: Colors.deepPurple),
            title: const Text('Elemental Realms'),
            children: [
              _tile(context, 'Sky / Space', Icons.cloud, const SkySpacePage()),
              _tile(context, 'Garden / Forest', Icons.grass, const GardenForestPage()),
              _tile(context, 'Workshop / Forge', Icons.build, const WorkshopForgePage()),
              _tile(context, 'Studio / Underwater', Icons.water, const StudioUnderwaterPage()),
              _tile(context, 'Root Cave / Underground', Icons.account_tree, const RootCavePage()),
              const Divider(),
              _tile(context, 'Realm Spirit Hall', Icons.shield, const SpiritPage()),
            ],
          ),

          ExpansionTile(
            leading: const Icon(Icons.book, color: Colors.deepPurple),
            title: const Text('User Logs'),
            children: [
              _tile(context, 'Journal', Icons.book, const JournalPage()),
              _tile(context, 'OmniTracker', Icons.auto_graph, const OmniTrackerPage()),
              _tile(context, 'Projects', Icons.folder_open, const ProjectsPage()),
              _tile(context, 'Calendar', Icons.calendar_today, const CalendarOverviewPage()),
              const Divider(),
              _tile(context, 'My Spirit Deck', Icons.style, const DeckPage()),
            ],
          ),

          ExpansionTile(
            leading: const Icon(Icons.settings, color: Colors.deepPurple),
            title: const Text('Settings & More'),
            children: [
              _tile(context, 'Collections', Icons.collections, const CollectionsPage()),
              _tile(context, 'Options', Icons.settings, const OptionsPage()),
              _tile(context, 'Trash', Icons.delete, const TrashPage()),
              _tile(context, 'Account', Icons.person, const AccountPage()),
            ],
          ),
        ]),
      ),
    );
  }

  Widget _tile(BuildContext ctx, String label, IconData icon, Widget page) {
    return ListTile(
      leading: Icon(icon, color: Colors.deepPurple),
      title: Text(label),
      onTap: () {
        Navigator.of(ctx).pop();
        Navigator.of(ctx).push(MaterialPageRoute(builder: (_) => page));
      },
    );
  }
}
