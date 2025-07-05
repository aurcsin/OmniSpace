// lib/pages/fusion_chamber_page.dart

import 'package:flutter/material.dart';
import 'package:omnispace/widgets/main_menu_drawer.dart';
import 'package:omnispace/widgets/help_button.dart';

/// Fusion Chamber Page
/// Allows combining spirits and artifacts into new items.
class FusionChamberPage extends StatefulWidget {
  const FusionChamberPage({Key? key}) : super(key: key);

  @override
  _FusionChamberPageState createState() => _FusionChamberPageState();
}

class _FusionChamberPageState extends State<FusionChamberPage> {
  final List<String> _selectedSpirits = [];
  final List<String> _selectedArtifacts = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MainMenuDrawer(),
      appBar: AppBar(
        title: const Text('Fusion Chamber'),
        actions: [
          HelpButton(
            helpTitle: 'Fusion Chamber Help',
            helpText: '''
• Select spirits and artifacts.  
• Combine them to create new items.  
• Discover unique hybrid creations.  ''',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Selected Spirits:', style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 8,
              children: _selectedSpirits.map((s) => Chip(label: Text(s))).toList(),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // TODO: open spirit picker
              },
              child: const Text('Pick Spirit'),
            ),
            const Divider(height: 32),
            const Text('Selected Artifacts:', style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 8,
              children: _selectedArtifacts.map((a) => Chip(label: Text(a))).toList(),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // TODO: open artifact picker
              },
              child: const Text('Pick Artifact'),
            ),
            const Spacer(),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.auto_fix_high),
                label: const Text('Fuse'),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16)),
                onPressed: _selectedSpirits.isNotEmpty && _selectedArtifacts.isNotEmpty
                    ? () {
                        // TODO: perform fusion logic
                      }
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
