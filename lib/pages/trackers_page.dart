// lib/pages/trackers_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/event.dart';         // used for Event fields (e.title, e.eventDate, e.isRecurring)
import '../models/goal.dart';          // used for Goal fields (g.title, g.progressNotes)
import '../models/task.dart';          // used for Task fields (t.description, t.isCompleted, t.recurringRule)
import '../models/tracker_type.dart';  // used for TrackerType in _createNewTracker

import '../services/event_service.dart';  // used to fetch and reorder events
import '../services/goal_service.dart';   // used to fetch and reorder goals
import '../services/task_service.dart';   // used to fetch, reorder, and toggle tasks

class TrackersPage extends StatefulWidget {
  const TrackersPage({Key? key}) : super(key: key);

  @override
  State<TrackersPage> createState() => _TrackersPageState();
}

class _TrackersPageState extends State<TrackersPage>
    with SingleTickerProviderStateMixin {
  late final TabController _controller;

  int get _tab => _controller.index;

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 3, vsync: this)
      ..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openForge(dynamic payload) {
    Navigator.pushNamed(context, '/forge', arguments: payload);
  }

  void _createNewTracker() {
    _openForge(TrackerType.values[_tab]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trackers'),
        bottom: TabBar(
          controller: _controller,
          tabs: const [
            Tab(text: 'Goals'),
            Tab(text: 'Tasks'),
            Tab(text: 'Events'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _controller,
        children: [
          _buildGoalsTab(),
          _buildTasksTab(),
          _buildEventsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewTracker,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildGoalsTab() {
    final goals = GoalService.instance.goals;
    if (goals.isEmpty) {
      return const Center(child: Text('No goals yet.'));
    }
    return ReorderableListView(
      onReorder: GoalService.instance.reorder,
      children: [
        for (final g in goals)
          ListTile(
            key: ValueKey(g.key),
            title: Text(g.title),
            subtitle: LinearProgressIndicator(
              value: (g.progressNotes.length / (g.progressNotes.isEmpty ? 1 : 10))
                  .clamp(0.0, 1.0),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _openForge(g),
            ),
          ),
      ],
    );
  }

  Widget _buildTasksTab() {
    final tasks = TaskService.instance.tasks;
    if (tasks.isEmpty) {
      return const Center(child: Text('No tasks yet.'));
    }
    return ReorderableListView(
      onReorder: TaskService.instance.reorder,
      children: [
        for (final t in tasks)
          CheckboxListTile(
            key: ValueKey(t.key),
            value: t.isCompleted,
            title: Text(t.description),
            subtitle: Text('${t.recurringRule ?? 'one-off'}'),
            onChanged: (_) {
              TaskService.instance.toggleComplete(t);
              setState(() {});
            },
            secondary: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _openForge(t),
            ),
          ),
      ],
    );
  }

  Widget _buildEventsTab() {
    final events = EventService.instance.events;
    if (events.isEmpty) {
      return const Center(child: Text('No events yet.'));
    }
    return ReorderableListView(
      onReorder: EventService.instance.reorder,
      children: [
        for (final e in events)
          ListTile(
            key: ValueKey(e.key),
            title: Text(e.title),
            subtitle: Text(
              '${DateFormat.jm().format(e.eventDate)}'
              '${e.isRecurring ? ' • Recurring' : ''}',
            ),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _openForge(e),
            ),
          ),
      ],
    );
  }
}
