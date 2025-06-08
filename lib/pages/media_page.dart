import 'package:flutter/material.dart';
import '../widgets/main_menu_drawer.dart';

class MediaPage extends StatelessWidget {
  const MediaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Media')),
      drawer: const MainMenuDrawer(),
      body: const Center(child: Text('Media gallery')),
    );
  }
}
