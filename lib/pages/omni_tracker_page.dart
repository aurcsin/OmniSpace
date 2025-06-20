// File: lib/pages/omni_tracker_page.dart

import 'package:flutter/material.dart';
import '../models/tracker.dart';
import '../models/tracker_type.dart';
import '../models/tracker_collection.dart';
import '../services/tracker_service.dart';
import '../services/tracker_collection_service.dart';
import '../widgets/main_menu_drawer.dart';
import 'tracker_forge_page.dart';
import 'tracker_view_page.dart';

class OmniTrackerPage extends StatefulWidget {
  const OmniTrackerPage({Key? key}) : super(key: key);

  @override
  _OmniTrackerPageState createState() => _OmniTrackerPageState();
}

class _OmniTrackerPageState extends State<OmniTrackerPage> {
  bool _selectionMode = false;
  final Set<String> _selected = {};
  bool _gridMode = true;

  List<Tracker> get _all => TrackerService.instance.all;
  List<TrackerCollection> get _cols => TrackerCollectionService.instance.all;

  IconData _iconFor(TrackerType t) {
    switch (t) {
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

  void _enterSelect(String id) {
    setState(() {
      _selectionMode = true;
      _selected.add(id);
    });
  }

  void _toggleSelect(String id) {
    setState(() {
      if (!_selected.remove(id)) _selected.add(id);
      if (_selected.isEmpty) _selectionMode = false;
    });
  }

  Future<void> _batchAddToCollection() async {
    // TODO: prompt existing/new collection and add all _selected IDs
  }

  void _showAddMenu() {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('New Tracker'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => TrackerForgePage()))
                    .then((_) => setState(() {}));
              },
            ),
            ListTile(
              leading: const Icon(Icons.folder_special),
              title: const Text('New Collection'),
              onTap: () {
                Navigator.pop(context);
                // TODO: open create-collection UI
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MainMenuDrawer(),
      appBar: AppBar(
        title: Text(
          _selectionMode
              ? '${_selected.length} selected'
              : 'OmniTracker',
        ),
        actions: [
          if (!_selectionMode)
            IconButton(
              icon: Icon(_gridMode ? Icons.list : Icons.grid_view),
              onPressed: () => setState(() => _gridMode = !_gridMode),
            ),
          if (_selectionMode)
            IconButton(
              icon: const Icon(Icons.folder_special),
              tooltip: 'Add to Collection',
              onPressed: _batchAddToCollection,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: _gridMode ? _buildGrid() : _buildList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_selectionMode) {
            setState(() {
              _selectionMode = false;
              _selected.clear();
            });
          } else {
            _showAddMenu();
          }
        },
        child: Icon(_selectionMode ? Icons.close : Icons.add),
      ),
    );
  }

  Widget _buildGrid() {
    return ListView(
      children: [
        ..._cols.map((col) {
          final members =
              _all.where((t) => col.trackerIds.contains(t.id)).toList();
          return ExpansionTile(
            title: Text('${col.name} (${members.length})'),
            children: members.map(_tileFor).toList(),
          );
        }),
        const Divider(),
        ExpansionTile(
          title: const Text('Ungrouped Trackers'),
          children: _all
              .where((t) => _cols.every((c) => !c.trackerIds.contains(t.id)))
              .map(_tileFor)
              .toList(),
        ),
      ],
    );
  }

  Widget _buildList() {
    return ListView(
      children: [
        ..._all
            .where((t) => _cols.every((c) => !c.trackerIds.contains(t.id)))
            .map(_tileFor),
        const Divider(),
        ..._cols.map((col) {
          return ExpansionTile(
            title: Text(col.name),
            children: _all
                .where((t) => col.trackerIds.contains(t.id))
                .map(_tileFor)
                .toList(),
          );
        }),
      ],
    );
  }

  Widget _tileFor(Tracker t) {
    final selected = _selected.contains(t.id);
    return ListTile(
      leading: _selectionMode
          ? Checkbox(
              value: selected,
              onChanged: (_) => _toggleSelect(t.id),
            )
          : Icon(_iconFor(t.type)),
      title: Text(t.title),
      onLongPress: () => _enterSelect(t.id),
      onTap: _selectionMode
          ? () => _toggleSelect(t.id)
          : () => Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => TrackerViewPage(tracker: t)))
              .then((_) => setState(() {})),
    );
  }
}
