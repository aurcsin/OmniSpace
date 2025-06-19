// File: lib/pages/omni_tracker_page.dart

import 'package:flutter/material.dart';

import '../models/tracker.dart';
import '../models/tracker_collection.dart';
import '../models/tracker_type.dart';
import '../services/tracker_service.dart';
import '../services/tracker_collection_service.dart';
import '../widgets/search_filter_bar.dart';
import '../services/search_filter_service.dart';
import '../widgets/main_menu_drawer.dart';
import 'tracker_forge_page.dart';
import 'tracker_view_page.dart';

class OmniTrackerPage extends StatefulWidget {
  const OmniTrackerPage({Key? key}) : super(key: key);

  @override
  _OmniTrackerPageState createState() => _OmniTrackerPageState();
}

class _OmniTrackerPageState extends State<OmniTrackerPage> {
  final _filter = SearchFilterService.instance;
  bool _gridMode = true;
  Set<String> _selectedTrackerIds = {};

  @override
  void initState() {
    super.initState();
    TrackerService.instance.init().then((_) => setState(() {}));
    TrackerCollectionService.instance.init().then((_) => setState(() {}));
    _filter.addListener(() => setState(() {}));
  }

  void _toggleTrackerSelect(String id) {
    setState(() {
      if (!_selectedTrackerIds.remove(id)) _selectedTrackerIds.add(id);
    });
  }

  Future<void> _batchAddToCollection() async {
    final colId = await showModalBottomSheet<String>(
      context: context,
      builder: (_) {
        final all = TrackerCollectionService.instance.all;
        return ListView(
          children: [
            ...all.map((c) => ListTile(
                  title: Text(c.name),
                  onTap: () => Navigator.pop(context, c.id),
                )),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('New Collection'),
              onTap: () async {
                final ctrl = TextEditingController();
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('New Collection'),
                    content: TextField(
                        controller: ctrl,
                        decoration:
                            const InputDecoration(labelText: 'Name')),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(_, false),
                          child: const Text('Cancel')),
                      ElevatedButton(
                          onPressed: () => Navigator.pop(_, true),
                          child: const Text('Create')),
                    ],
                  ),
                );
                if (ok == true && ctrl.text.trim().isNotEmpty) {
                  await TrackerCollectionService.instance.create(
                    name: ctrl.text.trim(),
                    ownerId: '',
                    trackerIds: [],
                  );
                  final newCol =
                      TrackerCollectionService.instance.all.last;
                  Navigator.pop(context, newCol.id);
                }
              },
            ),
          ],
        );
      },
    );
    if (colId != null) {
      await TrackerCollectionService.instance
          .addTrackersToCollection(colId, _selectedTrackerIds.toList());
      setState(() => _selectedTrackerIds.clear());
    }
  }

  List<Tracker> get _all => TrackerService.instance.all;
  List<TrackerCollection> get _collections =>
      TrackerCollectionService.instance.all;

  List<Tracker> get _filtered {
    final q = _filter.query.toLowerCase();
    return _all.where((t) {
      if (q.isNotEmpty && !t.title.toLowerCase().contains(q)) {
        return false;
      }
      if (t.start != null) {
        final date = t.start!;
        final f = _filter.focusDate;
        switch (_filter.viewMode) {
          case ViewMode.day:
            return date.year == f.year &&
                date.month == f.month &&
                date.day == f.day;
          case ViewMode.week:
            final st = f.subtract(const Duration(days: 3));
            final en = f.add(const Duration(days: 3));
            return date.isAfter(st) && date.isBefore(en);
          case ViewMode.month:
            return date.year == f.year && date.month == f.month;
          case ViewMode.year:
            return date.year == f.year;
        }
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MainMenuDrawer(),
      appBar: AppBar(
        title: _selectedTrackerIds.isEmpty
            ? const Text('OmniTracker')
            : Text('${_selectedTrackerIds.length} selected'),
        leading: _selectedTrackerIds.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.close),
                onPressed: () =>
                    setState(() => _selectedTrackerIds.clear()),
              ),
        actions: [
          if (_selectedTrackerIds.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.playlist_add),
              tooltip: 'Add to Collection',
              onPressed: _batchAddToCollection,
            ),
          if (_selectedTrackerIds.isEmpty)
            IconButton(
              icon:
                  Icon(_gridMode ? Icons.list : Icons.grid_view),
              onPressed: () =>
                  setState(() => _gridMode = !_gridMode),
            ),
        ],
      ),
      body: Column(
        children: [
          const SearchFilterBar(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child:
                  _gridMode ? _buildGrid() : _buildList(),
            ),
          ),
        ],
      ),
      floatingActionButton: _selectedTrackerIds.isEmpty
          ? FloatingActionButton(
              child: const Icon(Icons.add),
              onPressed: _showAddMenu,
            )
          : null,
    );
  }

  Widget _buildGrid() {
    return ListView(
      children: [
        ..._collections.map((col) {
          final members = _filtered
              .where((t) => col.trackerIds.contains(t.id))
              .toList();
          return ExpansionTile(
            title: Text('${col.name} (${members.length})'),
            children:
                members.map(_buildTrackerTile).toList(),
          );
        }),
        const Divider(),
        ExpansionTile(
          title: const Text('Ungrouped Trackers'),
          initiallyExpanded: true,
          children: _filtered
              .where((t) => _collections
                  .every((c) => !c.trackerIds.contains(t.id)))
              .map(_buildTrackerTile)
              .toList(),
        ),
      ],
    );
  }

  Widget _buildList() {
    return ListView(
      children: [
        ..._filtered
            .where((t) =>
                _collections.every((c) => !c.trackerIds.contains(t.id)))
            .map(_buildTrackerTile)
            .toList(),
        const Divider(),
        ..._collections.map((col) {
          final members = _filtered
              .where((t) => col.trackerIds.contains(t.id))
              .toList();
          return ExpansionTile(
            title: Text(col.name),
            children: members
                .map(_buildTrackerTile)
                .toList(),
          );
        }),
      ],
    );
  }

  Widget _buildTrackerTile(Tracker t) {
    final selected =
        _selectedTrackerIds.contains(t.id);
    return InkWell(
      onLongPress: () => _toggleTrackerSelect(t.id),
      onTap: selected
          ? () => _toggleTrackerSelect(t.id)
          : () => Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) =>
                        TrackerViewPage(tracker: t)),
              ),
      child: ListTile(
        leading: _selectedTrackerIds.isEmpty
            ? Icon(_iconFor(t.type))
            : Checkbox(
                value: selected,
                onChanged: (_) =>
                    _toggleTrackerSelect(t.id),
              ),
        title: Text(t.title),
      ),
    );
  }

  void _showAddMenu() {
    // existing implementation...
  }

  IconData _iconFor(TrackerType type) {
    switch (type) {
      case TrackerType.goal:
        return Icons.flag;
      case TrackerType.task:
        return Icons.check_box;
      case TrackerType.event:
        return Icons.event;
      case TrackerType.series:
        return Icons.link;
    }
  }
}
