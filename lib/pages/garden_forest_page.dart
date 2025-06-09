import 'package:flutter/material.dart';

import 'package:omnispace/widgets/main_menu_drawer.dart';




class GardenForestPage extends StatelessWidget {
  const GardenForestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Garden / Forest')),
      drawer: const MainMenuDrawer(),
      body: const Center(child: Text('Garden / Forest Page')),
    );
  }
}
