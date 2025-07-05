// lib/pages/omni_tracker_page.dart

import 'package:flutter/material.dart';

import '../models/tracker.dart';
import '../models/tracker_type.dart';
import '../models/tracker_collection.dart';

// avoid name collision
import '../services/tracker_service.dart' as tracker_svc;
import '../services/tracker_collection_service.dart';

import 'tracker_view_page.dart';
import 'tracker_forge_page.dart';

import '../widgets/main_menu_drawer.dart';
import '../widgets/help_button.dart';

class OmniTrackerPage extends StatefulWidget {
  const OmniTrackerPage({Key? key}) : super(key: key);
  @override
  _OmniTrackerPageState createState() => _OmniTrackerPageState();
}

class _OmniTrackerPageState extends State<OmniTrackerPage> {
  bool _selectionMode = false;
  final _selected = <String>{};
  bool _gridMode = true;

  List<Tracker> get _all => tracker_svc.TrackerService.instance.all;
  List<TrackerCollection> _cols = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _initCollections();
  }

  Future<void> _initCollections() async {
    await TrackerCollectionService.instance.init();
    setState(() {
      _cols = TrackerCollectionService.instance.all;
      _loading = false;
    });
  }

  IconData _iconFor(TrackerType t) {
    switch (t) {
      case TrackerType.goal:    return Icons.flag;
      case TrackerType.task:    return Icons.check_box;
      case TrackerType.event:   return Icons.event;
      case TrackerType.routine: return Icons.repeat;
      case TrackerType.series:  return Icons.link;
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
    await showModalBottomSheet<void>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text('Add to Collection', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          for (final col in _cols)
            ListTile(
              leading: const Icon(Icons.folder),
              title: Text(col.name),
              onTap: () async {
                for (final tid in _selected) {
                  await TrackerCollectionService.instance
                      .addToCollection(col.id, tid);
                }
                Navigator.pop(context);
                setState(() {
                  _selectionMode = false;
                  _selected.clear();
                });
              },
            ),
          ListTile(
            leading: const Icon(Icons.create_new_folder),
            title: const Text('New Collection'),
            onTap: () {
              Navigator.pop(context);
              _showCreateCollectionDialog();
            },
          ),
        ]),
      ),
    );
  }

  Future<void> _showCreateCollectionDialog() async {
    final ctl = TextEditingController();
    final created = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('New Collection'),
        content: TextField(controller: ctl, decoration: const InputDecoration(labelText: 'Name')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Create')),
        ],
      ),
    );
    if (created == true && ctl.text.trim().isNotEmpty) {
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      await TrackerCollectionService.instance.create(
        id: id,
        name: ctl.text.trim(),
        ownerId: 'self',
        trackerIds: [],
      );
      await _initCollections();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Created collection "${ctl.text.trim()}"')),
      );
    }
  }

  Future<void> _showAddMenu() async {
    final type = await showModalBottomSheet<TrackerType>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(leading: const Icon(Icons.flag),      title: const Text('New Goal'),    onTap: () => Navigator.pop(context, TrackerType.goal)),
          ListTile(leading: const Icon(Icons.check_box), title: const Text('New Task'),    onTap: () => Navigator.pop(context, TrackerType.task)),
          ListTile(leading: const Icon(Icons.event),     title: const Text('New Event'),   onTap: () => Navigator.pop(context, TrackerType.event)),
          ListTile(leading: const Icon(Icons.repeat),    title: const Text('New Routine'), onTap: () => Navigator.pop(context, TrackerType.routine)),
          ListTile(leading: const Icon(Icons.link),      title: const Text('New Series'),  onTap: () => Navigator.pop(context, TrackerType.series)),
        ]),
      ),
    );
    if (type != null) {
      final saved = await Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (_) => TrackerForgePage(type: type)),
      );
      if (saved == true) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      drawer: const MainMenuDrawer(),
      appBar: AppBar(
        title: Text(_selectionMode ? '${_selected.length} selected' : 'OmniTracker'),
        actions: [
          if (!_selectionMode) ...[
            HelpButton(
              helpTitle: 'Trackers Overview',
              helpText: '''
• Tap “+” to create a new tracker  
• Long‐press to select multiple  
• In selection mode, batch‐add them to a collection''',
            ),
            IconButton(
              icon: Icon(_gridMode ? Icons.list : Icons.grid_view),
              onPressed: () => setState(() => _gridMode = !_gridMode),
            ),
          ] else ...[
            IconButton(
              icon: const Icon(Icons.folder_special),
              onPressed: _batchAddToCollection,
            ),
          ],
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
        for (final col in _cols) ...[
          ExpansionTile(
            title: Text('${col.name} (${col.trackerIds.length})'),
            children: _all.where((t) => col.trackerIds.contains(t.id)).map(_tileFor).toList(),
          ),
        ],
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
        ..._all.where((t) => _cols.every((c) => !c.trackerIds.contains(t.id))).map(_tileFor),
        const Divider(),
        for (final col in _cols) ...[
          ExpansionTile(
            title: Text(col.name),
            children: _all.where((t) => col.trackerIds.contains(t.id)).map(_tileFor).toList(),
          ),
        ],
      ],
    );
  }

  Widget _tileFor(Tracker t) {
    final sel = _selected.contains(t.id);
    return ListTile(
      leading: _selectionMode
          ? Checkbox(value: sel, onChanged: (_) => _toggleSelect(t.id))
          : Icon(_iconFor(t.type)),
      title: Text(t.title.isEmpty ? '(No title)' : t.title),
      onLongPress: () => _enterSelect(t.id),
      onTap: _selectionMode
          ? () => _toggleSelect(t.id)
          : () => Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => TrackerViewPage(tracker: t)))
              .then((_) => setState(() {})),
    );
  }
}
