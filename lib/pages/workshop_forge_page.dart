// File: lib/pages/workshop_forge_page.dart

import 'package:flutter/material.dart';
import '../models/tracker.dart';
import '../models/tracker_type.dart';
import '../services/tracker_service.dart';
import 'tracker_view_page.dart';
import 'tracker_forge_page.dart';

class WorkshopForgePage extends StatefulWidget {
  const WorkshopForgePage({Key? key}) : super(key: key);

  @override
  State<WorkshopForgePage> createState() => _WorkshopForgePageState();
}

class _WorkshopForgePageState extends State<WorkshopForgePage> {
  List<Tracker> get _all => TrackerService.instance.all;

  @override
  Widget build(BuildContext context) {
    // Group trackers by type
    final Map<TrackerType, List<Tracker>> byType = {
      for (var t in TrackerType.values)
        t: _all.where((tr) => tr.type == t).toList()
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Workshop • Forge')),
      body: ListView(
        children: TrackerType.values.expand((type) {
          final list = byType[type]!;
          return [
            _sectionHeader(type),
            if (list.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text('No items here.'),
              )
            else
              ...list.map(_buildTile)
          ];
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => TrackerForgePage()))
            .then((_) => setState(() {})),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _sectionHeader(TrackerType type) {
    final label = type.name[0].toUpperCase() + type.name.substring(1);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(label,
          style:
              const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildTile(Tracker t) {
    return ListTile(
      title: Text(t.title),
      subtitle: Text(t.type.name),
      onTap: () => Navigator.of(context)
          .push(MaterialPageRoute(
              builder: (_) => TrackerViewPage(tracker: t)))
          .then((_) => setState(() {})),
    );
  }
}
