// File: lib/widgets/main_menu_drawer.dart

import 'package:flutter/material.dart';

import 'package:omnispace/pages/sky_space_page.dart';
import 'package:omnispace/pages/workshop_forge_page.dart';
import 'package:omnispace/pages/garden_forest_page.dart';
import 'package:omnispace/pages/studio_underwater_page.dart';
import 'package:omnispace/pages/root_cave_page.dart';
import 'package:omnispace/pages/journal_page.dart';
import 'package:omnispace/pages/collections_page.dart';
import 'package:omnispace/pages/tracker_page.dart';
import 'package:omnispace/pages/options_page.dart';
import 'package:omnispace/pages/account_page.dart';

/// A side drawer for navigating between the core zones and utility pages.
class MainMenuDrawer extends StatelessWidget {
  const MainMenuDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.deepPurple),
              child: Text(
                'OmniSpace',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Themed zones:
            _buildTile(
              context,
              icon: Icons.cloud,
              title: 'Sky / Space',
              page: const SkySpacePage(),
            ),
            _buildTile(
              context,
              icon: Icons.build,
              title: 'Workshop / Forge',
              page: const WorkshopForgePage(),
            ),
            _buildTile(
              context,
              icon: Icons.grass,
              title: 'Garden / Forest',
              page: const GardenForestPage(),
            ),
            _buildTile(
              context,
              icon: Icons.water,
              title: 'Studio / Underwater',
              page: const StudioUnderwaterPage(),
            ),
            _buildTile(
              context,
              icon: Icons.account_tree,
              title: 'Root Cave / Underground',
              page: const RootCavePage(),
            ),

            const Divider(),

            // Journal:
            _buildTile(
              context,
              icon: Icons.book,
              title: 'Journal',
              page: const JournalPage(),
            ),

            const Divider(),

            // Utilities:
            _buildTile(
              context,
              icon: Icons.collections,
              title: 'Collections',
              page: const CollectionsPage(),
            ),
            _buildTile(
              context,
              icon: Icons.checklist,
              title: 'Trackers',
              page: const TrackerPage(),
            ),
            _buildTile(
              context,
              icon: Icons.settings,
              title: 'Options',
              page: const OptionsPage(),
            ),
            _buildTile(
              context,
              icon: Icons.person,
              title: 'Account',
              page: const AccountPage(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Widget page,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.deepPurple),
      title: Text(title),
      onTap: () {
        Navigator.of(context).pop(); // close drawer
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => page),
        );
      },
    );
  }
}
