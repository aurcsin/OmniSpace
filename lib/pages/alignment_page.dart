// lib/pages/alignment_page.dart

import 'package:flutter/material.dart';
import 'package:omnispace/widgets/main_menu_drawer.dart';
import 'package:omnispace/widgets/help_button.dart';

/// Alignment Page
/// Users can view and edit their personal attributes,
/// core values, strengths, and alignment with spirits or elements.
class AlignmentPage extends StatefulWidget {
  const AlignmentPage({Key? key}) : super(key: key);

  @override
  _AlignmentPageState createState() => _AlignmentPageState();
}

class _AlignmentPageState extends State<AlignmentPage> {
  // Placeholder for user attributes
  final Map<String, String> _attributes = {
    'Core Value': 'Integrity',
    'Strength': 'Resilience',
    'Personality': 'Curious',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MainMenuDrawer(),
      appBar: AppBar(
        title: const Text('Alignment'),
        actions: [
          HelpButton(
            helpTitle: 'Alignment Help',
            helpText: '''
• Define your core values.  
• List your strengths.  
• Set your personality traits.  
• See how they align with elemental realms.  ''',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: _attributes.entries.map((e) {
            return Card(
              child: ListTile(
                title: Text(e.key),
                subtitle: Text(e.value),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () async {
                    final ctl = TextEditingController(text: e.value);
                    final updated = await showDialog<String?>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text('Edit ${e.key}'),
                        content: TextField(controller: ctl),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                          ElevatedButton(onPressed: () => Navigator.pop(context, ctl.text.trim()), child: const Text('Save')),
                        ],
                      ),
                    );
                    if (updated != null && updated.isNotEmpty) {
                      setState(() => _attributes[e.key] = updated);
                    }
                  },
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}