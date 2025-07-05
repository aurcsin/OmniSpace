// lib/pages/trash_page.dart

import 'package:flutter/material.dart';
import 'package:omnispace/widgets/main_menu_drawer.dart';
import 'package:omnispace/widgets/help_button.dart';

class TrashPage extends StatelessWidget {
  const TrashPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement your trash/recycle logic here
    return Scaffold(
      drawer: const MainMenuDrawer(),
      appBar: AppBar(
        title: const Text('Trash'),
        actions: [
          HelpButton(
            helpTitle: 'Trash Help',
            helpText: '''
• Deleted items appear here.  
• Swipe left to permanently delete.  
• Tap restore to bring an item back.''',
          )
        ],
      ),
      body: const Center(
        child: Text('No trashed items.'),
      ),
    );
  }
}
