// File: lib/pages/omni_tracker_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../models/tracker.dart';
import '../models/tracker_type.dart';
import '../models/tracker_collection.dart';
import '../services/tracker_service.dart';
import '../services/tracker_collection_service.dart';
import '../widgets/main_menu_drawer.dart';
import 'tracker_forge_page.dart';
import 'tracker_view_page.dart';

class OmniTrackerPage extends StatefulWidget {
  const OmniTrackerPage({super.key});

  @override
  _OmniTrackerPageState createState() => _OmniTrackerPageState();
}

class _OmniTrackerPageState extends State<OmniTrackerPage> {
  bool _gridMode = true;

  List<Tracker> get _all => TrackerService.instance.all;
  List<TrackerCollection> get _collections =>
      TrackerCollectionService.instance.all;

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
                showModalBottomSheet<TrackerType>(
                  context: context,
                  builder: (_) => SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: TrackerType.values.map((type) {
                        return ListTile(
                          leading: Icon(_iconFor(type)),
                          title: Text(type.name[0].toUpperCase() +
                              type.name.substring(1)),
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.of(context)
                                .push(MaterialPageRoute(
                              builder: (_) => TrackerForgePage(type: type),
                            ))
                                .then((_) => setState(() {}));
                          },
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.folder_special),
              title: const Text('New Collection'),
              subtitle: const Text('Group multiple trackers'),
              onTap: () async {
                Navigator.pop(context);
                await _createCollection();
                setState(() {});
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createCollection() async {
    final available = _all;
    final selected = <String>{};
    final nameCtl = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('New Tracker Collection'),
        content: StatefulBuilder(builder: (ctx, setSt) {
          return SizedBox(
            height: 300,
            width: 300,
            child: Column(
              children: [
                TextField(
                  controller: nameCtl,
                  decoration: const InputDecoration(labelText: 'Collection Name'),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView(
                    children: available.map((t) {
                      return CheckboxListTile(
                        value: selected.contains(t.id),
                        title: Text(t.title),
                        secondary: Icon(_iconFor(t.type)),
                        onChanged: (_) => setSt(() {
                          if (!selected.remove(t.id)) selected.add(t.id);
                        }),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
        }),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (nameCtl.text.trim().isNotEmpty) {
                await TrackerCollectionService.instance
                    .create(nameCtl.text.trim(), selected.toList());
              }
              Navigator.pop(context);
            },
            child: const Text('Create'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MainMenuDrawer(),
      appBar: AppBar(
        title: const Text('OmniTracker'),
        actions: [
          IconButton(
            icon: Icon(_gridMode ? Icons.list : Icons.grid_view),
            onPressed: () => setState(() => _gridMode = !_gridMode),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: _gridMode
            // GRID: Collections first, then un‐associated
            ? ListView(
                children: [
                  // Collections
                  ..._collections.map((col) {
                    final colTrackers = _all
                        .where((t) => col.trackerIds.contains(t.id))
                        .toList();
                    return ExpansionTile(
                      title: Text('${col.name} (${colTrackers.length})'),
                      children: colTrackers.isEmpty
                          ? [const ListTile(title: Text('— none —'))]
                          : colTrackers
                              .map((t) => ListTile(
                                    leading: Icon(_iconFor(t.type)),
                                    title: Text(t.title),
                                    onTap: () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            TrackerViewPage(tracker: t),
                                      ),
                                    ),
                                  ))
                              .toList(),
                    );
                  }),

                  const Divider(),

                  // Un‐associated trackers
                  ExpansionTile(
                    title: const Text('Ungrouped Trackers'),
                    initiallyExpanded: true,
                    children: _all
                        .where((t) => _collections.every(
                            (col) => !col.trackerIds.contains(t.id)))
                        .map((t) => ListTile(
                              leading: Icon(_iconFor(t.type)),
                              title: Text(t.title),
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      TrackerViewPage(tracker: t),
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ],
              )
            // LIST: show loose first, then collections
            : ListView(
                children: [
                  // Loose
                  ..._all
                      .where((t) =>
                          _collections.every((c) => !c.trackerIds.contains(t.id)))
                      .map((t) => ListTile(
                            leading: Icon(_iconFor(t.type)),
                            title: Text(t.title),
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    TrackerViewPage(tracker: t),
                              ),
                            ),
                          )),

                  const Divider(),

                  // Collections
                  ..._collections.map((col) {
                    return ExpansionTile(
                      title: Text(col.name),
                      children: _all
                          .where((t) => col.trackerIds.contains(t.id))
                          .map((t) => ListTile(
                                leading: Icon(_iconFor(t.type)),
                                title: Text(t.title),
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        TrackerViewPage(tracker: t),
                                  ),
                                ),
                              ))
                          .toList(),
                    );
                  }),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddMenu,
        child: const Icon(Icons.add),
      ),
    );
  }
}
