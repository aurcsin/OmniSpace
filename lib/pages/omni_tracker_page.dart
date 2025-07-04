// lib/pages/omni_tracker_page.dart

import 'package:flutter/material.dart';

import '../models/tracker.dart';
import '../models/tracker_type.dart';
import '../models/tracker_collection.dart';

// Alias the tracker service import to avoid name collision
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
  final Set<String> _selected = {};
  bool _gridMode = true;

  List<Tracker> get _all =>
      tracker_svc.TrackerService.instance.all;
  List<TrackerCollection> get _cols =>
      TrackerCollectionService.instance.all;

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
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Text(
              'Add to Collection',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          for (final col in _cols)
            ListTile(
              leading: const Icon(Icons.folder),
              title: Text(col.name),
              onTap: () async {
                // Add each selected tracker to this collection
                final svc = TrackerCollectionService.instance;
                for (final tid in _selected) {
                  await svc.addToCollection(col.id, tid);
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
    final controller = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('New Collection'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Collection Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                final id = DateTime.now().millisecondsSinceEpoch.toString();
                await TrackerCollectionService.instance.create(
                  id: id,
                  name: name,
                  ownerId: 'self',
                  trackerIds: _selected.toList(),
                );
                setState(() {
                  _selectionMode = false;
                  _selected.clear();
                });
              }
              Navigator.pop(context);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showAddMenu() {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('New Tracker'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context)
                  .push(MaterialPageRoute(
                    builder: (_) => const TrackerForgePage(),
                  ))
                  .then((_) => setState(() {}));
            },
          ),
          ListTile(
            leading: const Icon(Icons.folder_special),
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
          if (!_selectionMode) ...[
            HelpButton(
              helpTitle: 'Trackers Overview',
              helpText: '''
• Toggle grid/list view.  
• Tap a tracker to view details.  
• Long-press to select multiple.  
• In selection mode, add to a collection.''',
            ),
            IconButton(
              icon: Icon(
                  _gridMode ? Icons.list : Icons.grid_view),
              onPressed: () =>
                  setState(() => _gridMode = !_gridMode),
            ),
          ] else ...[
            IconButton(
              icon: const Icon(Icons.folder_special),
              tooltip: 'Add to Collection',
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
        child: Icon(
            _selectionMode ? Icons.close : Icons.add),
      ),
    );
  }

  Widget _buildGrid() {
    return ListView(
      children: [
        for (final col in _cols) ...[
          ExpansionTile(
            title:
                Text('${col.name} (${col.trackerIds.length})'),
            children: _all
                .where(
                    (t) => col.trackerIds.contains(t.id))
                .map(_tileFor)
                .toList(),
          ),
        ],
        const Divider(),
        ExpansionTile(
          title: const Text('Ungrouped Trackers'),
          children: _all
              .where((t) => _cols.every(
                  (c) => !c.trackerIds.contains(t.id)))
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
            .where((t) => _cols.every((c) =>
                !c.trackerIds.contains(t.id)))
            .map(_tileFor),
        const Divider(),
        for (final col in _cols) ...[
          ExpansionTile(
            title: Text(col.name),
            children: _all
                .where(
                    (t) => col.trackerIds.contains(t.id))
                .map(_tileFor)
                .toList(),
          ),
        ],
      ],
    );
  }

  Widget _tileFor(Tracker t) {
    final isSelected = _selected.contains(t.id);
    return ListTile(
      leading: _selectionMode
          ? Checkbox(
              value: isSelected,
              onChanged: (_) => _toggleSelect(t.id),
            )
          : Icon(_iconFor(t.type)),
      title: Text(t.title),
      onLongPress: () => _enterSelect(t.id),
      onTap: _selectionMode
          ? () => _toggleSelect(t.id)
          : () => Navigator.of(context)
              .push(MaterialPageRoute(
                builder: (_) =>
                    TrackerViewPage(tracker: t),
              ))
              .then((_) => setState(() {})),
    );
  }
}
