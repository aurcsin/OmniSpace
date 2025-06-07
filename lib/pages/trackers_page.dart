import 'package:flutter/material.dart';
import '../widgets/main_menu_drawer.dart';

class TrackersPage extends StatelessWidget {
  const TrackersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Trackers'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Goals'),
              Tab(text: 'Tasks'),
              Tab(text: 'Events'),
            ],
          ),
        ),
        drawer: const MainMenuDrawer(),
        body: const TabBarView(
          children: [
            Center(child: Text('Goals list')),
            Center(child: Text('Tasks list')),
            Center(child: Text('Events list')),
          ],
        ),
      ),
    );
  }
}
