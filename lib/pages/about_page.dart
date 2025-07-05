import 'package:flutter/material.dart';
import 'package:omnispace/widgets/main_menu_drawer.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MainMenuDrawer(),
      appBar: AppBar(title: const Text('About OmniSpace')),
      body: const Center(child: Text('OmniSpace version & credits')),
    );
  }
}
