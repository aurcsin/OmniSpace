// lib/widgets/main_menu_drawer.dart

import 'package:flutter/material.dart';

import '../pages/sky_space_page.dart';
import '../pages/workshop_forge_page.dart';
import '../pages/garden_forest_page.dart';
import '../pages/studio_underwater_page.dart';
import '../pages/root_cave_page.dart';
import '../pages/journal_page.dart';
import '../pages/collections_page.dart';
import '../pages/options_page.dart';
import '../pages/account_page.dart';
import '../pages/trackers_page.dart';
import '../pages/media_page.dart';

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

            // Themed real page entries:
            _buildTile(
              context,
              icon: Icons.cloud,
              title: 'Sky / Space',
              route: '/sky',
            ),
            _buildTile(
              context,
              icon: Icons.build,
              title: 'Workshop / Forge',
              route: '/forge',
            ),
            _buildTile(
              context,
              icon: Icons.grass,
              title: 'Garden / Forest',
              route: '/garden',
            ),
            _buildTile(
              context,
              icon: Icons.water,
              title: 'Studio / Underwater',
              route: '/studio',
            ),
            _buildTile(
              context,
              icon: Icons.account_tree,
              title: 'Root Cave / Underground',
              route: '/root-cave',
            ),

            const Divider(),

            // Neutral Journal page now after Root Cave:
            _buildTile(
              context,
              icon: Icons.book,
              title: 'Journal',
              route: '/journal',
            ),

            _buildTile(
              context,
              icon: Icons.track_changes,
              title: 'Trackers',
              route: '/trackers',
            ),

            _buildTile(
              context,
              icon: Icons.perm_media,
              title: 'Media',
              route: '/media',
            ),

            const Divider(),

            // Utility pages:
            _buildTile(
              context,
              icon: Icons.collections,
              title: 'Collections',
              route: '/collections',
            ),
            _buildTile(
              context,
              icon: Icons.settings,
              title: 'Options',
              route: '/options',
            ),
            _buildTile(
              context,
              icon: Icons.person,
              title: 'Account',
              route: '/account',
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
    required String route,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.deepPurple),
      title: Text(title),
      onTap: () {
        Navigator.of(context).pop(); // close drawer
        Navigator.pushNamed(context, route);
      },
    );
  }
}
