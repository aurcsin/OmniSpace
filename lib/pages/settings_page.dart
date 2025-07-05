import 'package:flutter/material.dart';
import 'package:omnispace/widgets/main_menu_drawer.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MainMenuDrawer(),
      appBar: AppBar(title: const Text('Settings')),
      body: const Center(child: Text('Configuration & preferences')),
    );
  }
}
