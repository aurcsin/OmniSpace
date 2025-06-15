// File: lib/pages/tracker_page.dart

import 'package:flutter/material.dart';
import '../models/tracker.dart';
import '../models/tracker_type.dart';
import '../services/tracker_service.dart';

class TrackerPage extends StatefulWidget {
  const TrackerPage({super.key});

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
        title: const Text('Tracker'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Goal'),
            Tab(text: 'Task'),
            Tab(text: 'Event'),
            Tab(text: 'Series'),
          ],
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
        // TODO: implement reordering logic
      },
      itemBuilder: (context, index) {
        final tracker = trackers[index];
        return ListTile(
          key: ValueKey(tracker.id),
          title: Text(tracker.title),
          subtitle: Text(_subtitleFor(tracker, type)),
          onTap: () => Navigator.pushNamed(
            context,
            '/trackerDetail',
            arguments: tracker,
          ),
          trailing: IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.pushNamed(
              context,
              '/forge',
              arguments: tracker,
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
        return 'Progress: ${pct}%';
      case TrackerType.task:
        return 'Frequency: ${tracker.frequency ?? 'once'}';
      case TrackerType.event:
        return tracker.start != null
            ? 'At ${tracker.start!.toLocal()}'
            : 'No date';
      case TrackerType.series:
        return '${tracker.childIds.length} items';
    }
  }

  void _createNewTracker() {
    final type = TrackerType.values[_tabController.index];
    Navigator.pushNamed(context, '/forge', arguments: type);
  }
}
