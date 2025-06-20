// File: lib/pages/tracker_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/tracker.dart';
import '../models/tracker_type.dart';
import '../services/tracker_service.dart';
import 'tracker_forge_page.dart';
import 'tracker_view_page.dart';

class TrackerPage extends StatefulWidget {
  const TrackerPage({Key? key}) : super(key: key);
  @override
  State<TrackerPage> createState() => _TrackerPageState();
}

class _TrackerPageState extends State<TrackerPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: TrackerType.values.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Tracker> _trackersOfType(TrackerType type) =>
      TrackerService.instance.all.where((t) => t.type == type).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trackers'),
        bottom: TabBar(
          controller: _tabController,
          tabs: TrackerType.values.map((t) {
            final label = t.name[0].toUpperCase() + t.name.substring(1);
            return Tab(text: label);
          }).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children:
            TrackerType.values.map((type) => _buildTrackerList(type)).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewTracker,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTrackerList(TrackerType type) {
    final trackers = _trackersOfType(type);
    if (trackers.isEmpty) {
      return const Center(child: Text('No items yet.'));
    }
    return ReorderableListView.builder(
      itemCount: trackers.length,
      onReorder: (oldIndex, newIndex) {
        // TODO: reorder persistence
      },
      itemBuilder: (context, index) {
        final tracker = trackers[index];
        return ListTile(
          key: ValueKey(tracker.id),
          title: Text(tracker.title),
          subtitle: Text(_subtitleFor(tracker, type)),
          onTap: () => Navigator.of(context)
              .push(MaterialPageRoute(
                  builder: (_) => TrackerViewPage(tracker: tracker)))
              .then((_) => setState(() {})),
          trailing: IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (_) =>
                      TrackerForgePage(tracker: tracker, type: type)),
            ),
          ),
        );
      },
    );
  }

  String _subtitleFor(Tracker tracker, TrackerType type) {
    switch (type) {
      case TrackerType.goal:
        final pct = ((tracker.progress ?? 0) * 100).round();
        return 'Progress: $pct%';
      case TrackerType.event:
        return tracker.start != null
            ? 'At ${DateFormat.yMMMd().add_jm().format(tracker.start!)}'
            : 'No date';
      case TrackerType.routine:
        return 'Routine: ${tracker.frequency ?? 'daily'}';
      case TrackerType.series:
        return '${tracker.childIds.length} items';
    }
    // Fallback so the method always returns a non-null String:
    return '';
  }

  void _createNewTracker() {
    final type = TrackerType.values[_tabController.index];
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => TrackerForgePage(type: type)));
  }
}
