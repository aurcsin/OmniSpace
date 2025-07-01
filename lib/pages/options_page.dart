// File: lib/pages/options_page.dart

import 'package:flutter/material.dart';

import '../services/sync_service.dart';
import '../services/notification_service.dart';
import '../widgets/main_menu_drawer.dart';

class OptionsPage extends StatefulWidget {
  const OptionsPage({Key? key}) : super(key: key);
  @override
  State<OptionsPage> createState() => _OptionsPageState();
}

class _OptionsPageState extends State<OptionsPage> {
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    NotificationService.instance.getEnabled().then((value) {
      setState(() => _notificationsEnabled = value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MainMenuDrawer(),
      appBar: AppBar(title: const Text('Options & Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Enable Tracker Reminders'),
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() => _notificationsEnabled = value);
              NotificationService.instance.setEnabled(value);
            },
          ),
          ListTile(
            leading: const Icon(Icons.sync),
            title: const Text('Sync Now'),
            onTap: () async {
              try {
                await SyncService.instance.syncAll();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sync complete')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Sync failed: $e')),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About OmniSpace'),
            onTap: () => showAboutDialog(
              context: context,
              applicationName: 'OmniSpace',
              applicationVersion: '1.0.0+1',
              children: const [
                Text('Your personal elemental journaling app.'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
