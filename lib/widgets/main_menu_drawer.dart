// lib/widgets/main_menu_drawer.dart

import 'package:flutter/material.dart';

/// Global navigation drawer for OmniSpace.
class MainMenuDrawer extends StatelessWidget {
  const MainMenuDrawer({Key? key}) : super(key: key);

  Widget _sectionTitle(String title) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 4),
        child: Text(title.toUpperCase(),
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 12)),
      );

  Widget _tile(
      BuildContext ctx, String title, IconData icon, String route) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.of(ctx).pop();
        Navigator.of(ctx).pushReplacementNamed(route);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(padding: EdgeInsets.zero, children: [
        const DrawerHeader(
          decoration: BoxDecoration(color: Colors.blue),
          child: Text('OmniSpace',
              style: TextStyle(color: Colors.white, fontSize: 24)),
        ),

        // ─── User Logs ───────────────────────────────────────────────────────
        _sectionTitle('User Logs'),
        _tile(context, 'Journal', Icons.book, '/journal'),
        _tile(context, 'Trackers', Icons.track_changes, '/trackers'),
        _tile(context, 'Projects', Icons.folder_open, '/projects'),
        _tile(context, 'Collections', Icons.collections, '/collections'),
        _tile(context, 'Calendar', Icons.calendar_today, '/calendar'),

        // ─── Spirit Board ────────────────────────────────────────────────────
        _sectionTitle('Spirit Board'),
        _tile(context, 'Alignment', Icons.adjust, '/alignment'),
        _tile(context, 'Deck', Icons.style, '/deck'),
        _tile(context, 'Spirit Hall', Icons.account_tree, '/spirithall'),
        _tile(context, 'Stats', Icons.bar_chart, '/stats'),

        // ─── Elemental ────────────────────────────────────────────────────────
        _sectionTitle('Elements'),
        _tile(context, 'Sky', Icons.cloud, '/sky'),
        _tile(context, 'Forge', Icons.local_fire_department, '/forge'),
        _tile(context, 'Garden', Icons.eco, '/forest'),
        _tile(context, 'Studio', Icons.water, '/underwater'),
        _tile(context, 'Root Cave', Icons.home, '/cave'),

        // ─── Options ─────────────────────────────────────────────────────────
        _sectionTitle('Options'),
        _tile(context, 'Account', Icons.person, '/account'),
        _tile(context, 'Settings', Icons.settings, '/settings'),
        _tile(context, 'Trash', Icons.delete, '/trash'),

        // ─── About ───────────────────────────────────────────────────────────
        _sectionTitle('About'),
        _tile(context, 'About OmniSpace', Icons.info, '/about'),
      ]),
    );
  }
}
