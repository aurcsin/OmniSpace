// File: lib/pages/tracker_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/tracker.dart';
import '../models/tracker_type.dart';
import '../services/tracker_service.dart';
import '../services/omni_note_service.dart';
import 'note_detail_page.dart' as detail;

class TrackerPage extends StatefulWidget {
  const TrackerPage({super.key});

  @override
  State<TrackerPage> createState() => _TrackerPageState();
}

class _TrackerPageState extends State<TrackerPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final List<TrackerType> _tabOrder = const [
    TrackerType.goal,
    TrackerType.event,
    TrackerType.task,
    TrackerType.series,
  ];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabOrder.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Tracker> _trackersOfType(TrackerType type) {
    final q = _searchQuery.toLowerCase();
    return TrackerService.instance.all
        .where((t) => t.type == type && t.title.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<TrackerService>.value(
      value: TrackerService.instance,
      child: Consumer<TrackerService>(
        builder: (_, __, ___) => Scaffold(
          appBar: AppBar(
            title: const Text('Tracker'),
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Goal'),
                Tab(text: 'Event'),
                Tab(text: 'Task'),
                Tab(text: 'Series'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children:
                _tabOrder.map((type) => _buildTrackerTab(type)).toList(),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _createNewTracker,
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }

  Widget _buildTrackerTab(TrackerType type) {
    final trackers = _trackersOfType(type);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Search…',
            ),
            onChanged: (v) => setState(() => _searchQuery = v),
          ),
        ),
        Expanded(
          child: trackers.isEmpty
              ? const Center(child: Text('No items yet.'))
              : ReorderableListView.builder(
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
                      trailing: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => Navigator.pushNamed(
                          context,
                          '/forge',
                          arguments: tracker,
                        ),
                      ),
                      onTap: () => _showLinkedNotes(context, tracker),
                    );
                  },
                ),
        ),
      ],
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
    final type = _tabOrder[_tabController.index];
    Navigator.pushNamed(context, '/forge', arguments: type);
  }

  Future<void> _showLinkedNotes(BuildContext context, Tracker tracker) async {
    final noteIds = TrackerService.instance.notesForTracker(tracker.id);
    final notes = OmniNoteService.instance.notes
        .where((n) => noteIds.contains(n.id))
        .toList();
    await showModalBottomSheet(
      context: context,
      builder: (_) => ListView(
        shrinkWrap: true,
        children: [
          ListTile(title: Text(tracker.title, style: const TextStyle(fontWeight: FontWeight.bold))),
          const Divider(),
          for (final note in notes)
            ListTile(
              title: Text(note.title.isNotEmpty ? note.title : '(No Title)'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => detail.NoteDetailPage(omniNote: note),
                  ),
                );
              },
            ),
          if (notes.isEmpty)
            const ListTile(title: Text('No linked notes.')),
        ],
      ),
    );
  }
}
