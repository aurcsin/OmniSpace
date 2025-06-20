// lib/pages/omni_tracker_page.dart

import 'package:flutter/material.dart';

import '../models/tracker.dart';
import '../models/tracker_type.dart';
import '../models/tracker_collection.dart';
import '../services/tracker_service.dart';
import '../services/tracker_collection_service.dart';
import '../services/auth_service.dart';
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
  Future<List<TrackerCollection>> get _cols async => await TrackerCollectionService.instance.all;

  IconData _iconFor(TrackerType t) {
    switch (t) {
      case TrackerType.goal:
        return Icons.flag;
      case TrackerType.event:
        return Icons.event;
      case TrackerType.routine:
        return Icons.repeat;
      case TrackerType.series:
        return Icons.collections;
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
    final nameCtl = TextEditingController();
    final cols = await _cols;

    final picked = await showDialog<TrackerCollection>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Add to Collection'),
          content: SizedBox(
            width: 300,
            height: 400,
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      ...cols.map((c) => ListTile(
                            title: Text(c.name),
                            onTap: () => Navigator.pop(ctx, c),
                          )),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.add),
                        title: const Text('New Collection'),
                        onTap: () => showDialog<bool>(
                          context: ctx,
                          builder: (ctx2) => AlertDialog(
                            title: const Text('New Collection'),
                            content: TextField(
                              controller: nameCtl,
                              decoration: const InputDecoration(labelText: 'Name'),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx2, false),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(ctx2, true),
                                child: const Text('Create'),
                              ),
                            ],
                          ),
                        ).then((ok) async {
                          if (ok == true && nameCtl.text.trim().isNotEmpty) {
                            final ownerId = AuthService.instance.currentUserId;
                            final newCol = TrackerCollection(
                              id: DateTime.now().millisecondsSinceEpoch.toString(),
                              name: nameCtl.text.trim(),
                              ownerId: ownerId,
                              trackerIds: [],
                            );
                            await TrackerCollectionService.instance.save(newCol);
                            Navigator.pop(ctx, newCol);
                          }
                        }),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (picked != null) {
      for (var id in _selected) {
        if (!picked.trackerIds.contains(id)) {
          picked.trackerIds.add(id);
        }
      }
      await TrackerCollectionService.instance.save(picked);
      setState(() {
        _selectionMode = false;
        _selected.clear();
      });
    }
  }

  Future<void> _showNewTrackerTypePicker() async {
    final type = await showModalBottomSheet<TrackerType>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: TrackerType.values.map((t) {
            return ListTile(
              leading: Icon(_iconFor(t)),
              title: Text('${t.name[0].toUpperCase()}${t.name.substring(1)}'),
              onTap: () => Navigator.pop(context, t),
            );
          }).toList(),
        ),
      ),
    );

    if (type != null) {
      await Navigator.of(context)
          .push<Tracker>(MaterialPageRoute(builder: (_) => TrackerForgePage(type: type)))
          .then((_) => setState(() {}));
    }
  }

  void _showAddMenu() {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('New Tracker'),
              onTap: () {
                Navigator.pop(context);
                _showNewTrackerTypePicker();
              },
            ),
            ListTile(
              leading: const Icon(Icons.folder_special),
              title: const Text('New Collection'),
              onTap: () {
                Navigator.pop(context);
                _batchAddToCollection();
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
        title: Text(_selectionMode ? '${_selected.length} selected' : 'Trackers'),
        actions: [
          if (!_selectionMode)
            IconButton(
              icon: Icon(_gridMode ? Icons.list : Icons.grid_view),
              onPressed: () => setState(() => _gridMode = !_gridMode),
            ),
          if (_selectionMode)
            IconButton(
              icon: const Icon(Icons.folder_special),
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
    return FutureBuilder<List<TrackerCollection>>(
      future: _cols,
      builder: (context, snap) {
        final cols = snap.data ?? [];
        return ListView(
          children: [
            ...cols.map((col) {
              final members = _all.where((t) => col.trackerIds.contains(t.id)).toList();
              return ExpansionTile(
                title: Text('${col.name} (${members.length})'),
                children: members.map(_tileFor).toList(),
              );
            }),
            const Divider(),
            ExpansionTile(
              title: const Text('Ungrouped'),
              children: _all.where((t) => cols.every((c) => !c.trackerIds.contains(t.id))).map(_tileFor).toList(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildList() {
    return FutureBuilder<List<TrackerCollection>>(
      future: _cols,
      builder: (context, snap) {
        final cols = snap.data ?? [];
        return ListView(
          children: [
            ..._all.where((t) => cols.every((c) => !c.trackerIds.contains(t.id))).map(_tileFor),
            const Divider(),
            ...cols.map((col) {
              final members = _all.where((t) => col.trackerIds.contains(t.id)).toList();
              return ExpansionTile(
                title: Text(col.name),
                children: members.map(_tileFor).toList(),
              );
            }),
          ],
        );
      },
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
