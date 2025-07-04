// lib/pages/tracker_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:omnispace/models/tracker.dart';
import 'package:omnispace/models/tracker_type.dart';
import 'package:omnispace/services/tracker_service.dart';
import 'package:omnispace/widgets/main_menu_drawer.dart';
import 'package:omnispace/pages/tracker_forge_page.dart';
import 'package:omnispace/pages/tracker_view_page.dart';

class TrackerPage extends StatefulWidget {
  const TrackerPage({Key? key}) : super(key: key);

  @override
  State<TrackerPage> createState() => _TrackerPageState();
}

class _TrackerPageState extends State<TrackerPage> {
  final _service = TrackerService.instance;

  @override
  Widget build(BuildContext context) {
    final items = _service.ofType(TrackerType.goal);
    return Scaffold(
      drawer: const MainMenuDrawer(),
      appBar: AppBar(title: const Text('Trackers')),
      body: ReorderableListView(
        onReorder: (oldIndex, newIndex) {
          if (newIndex > oldIndex) newIndex--;
          final id = items[oldIndex].id;
          _service.reorder(id, newIndex);
          setState(() {});
        },
        children: [
          for (final t in items)
            ListTile(
              key: ValueKey(t.id),
              leading: Icon(_iconFor(t.type)),
              title: Text(t.title),
              subtitle: Text(t.type.name.toUpperCase()),
              onTap: () async {
                final updated = await Navigator.of(context).push<Tracker>(
                  MaterialPageRoute(builder: (_) => TrackerViewPage(tracker: t)),
                );
                if (updated != null) setState(() {});
              },
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newTracker = await Navigator.of(context).push<Tracker>(
            MaterialPageRoute(builder: (_) => const TrackerForgePage(type: TrackerType.goal)),
          );
          if (newTracker != null) setState(() {});
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  IconData _iconFor(TrackerType type) {
    switch (type) {
      case TrackerType.goal:
        return Icons.flag;
      case TrackerType.task:
        return Icons.check_box;
      case TrackerType.event:
        return Icons.event;
      case TrackerType.routine:
        return Icons.repeat;
      case TrackerType.series:
        return Icons.link;
    }
  }
}
