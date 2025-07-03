// File: lib/pages/omni_tracker_page.dart

import 'package:flutter/material.dart';

import '../models/tracker.dart';
import '../models/tracker_type.dart';
import '../models/tracker_collection.dart';
import '../services/tracker_service.dart';
import '../services/tracker_collection_service.dart';
import '../widgets/main_menu_drawer.dart';
import '../widgets/help_button.dart';
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

  /// Add the selected trackers into an existing collection
  Future<void> _batchAddToCollection() async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'Add to Collection',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ..._cols.map((col) {
            return ListTile(
              leading: const Icon(Icons.folder),
              title: Text(col.name),
              onTap: () async {
                col.trackerIds.addAll(_selected);
                await TrackerCollectionService.instance.save(col);
                Navigator.pop(context);
                setState(() {
                  _selectionMode = false;
                  _selected.clear();
                });
              },
            );
          }),
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

  /// Prompt for a new collection name, then create it
  Future<void> _showCreateCollectionDialog() async {
    final controller = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Collection'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Collection Name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Create')),
        ],
      ),
    );
    if (ok == true) {
      final name = controller.text.trim();
      if (name.isNotEmpty) {
        final id = DateTime.now().millisecondsSinceEpoch.toString();
        await TrackerCollectionService.instance.create(
          id: id,
          name: name,
          ownerId: 'self', // TODO: replace with real user ID
          trackerIds: _selected.toList(),
        );
        setState(() {
          _selectionMode = false;
          _selected.clear();
        });
      }
    }
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
                  .push(MaterialPageRoute(builder: (_) => const TrackerForgePage()))
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
        title: Text(_selectionMode ? '${_selected.length} selected' : 'OmniTracker'),
        actions: [
          if (!_selectionMode) ...[
            HelpButton(
              helpTitle: 'Trackers Overview',
              helpText: '''
• Toggle between grid and list views with the view icon.  
• Tap “+” to add a new tracker or collection.  
• Long-press a tracker to enter selection mode.  
• In selection mode, use the folder icon to batch add to collections.''',
            ),
            IconButton(
              icon: Icon(_gridMode ? Icons.list : Icons.grid_view),
              onPressed: () => setState(() => _gridMode = !_gridMode),
            ),
          ],
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
          final members = _all.where((t) => col.trackerIds.contains(t.id)).toList();
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
          ? Checkbox(value: selected, onChanged: (_) => _toggleSelect(t.id))
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
