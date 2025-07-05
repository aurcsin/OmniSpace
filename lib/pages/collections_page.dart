// lib/pages/collections_page.dart

import 'package:flutter/material.dart';
import 'package:omnispace/models/note_collection.dart';
import 'package:omnispace/models/tracker_collection.dart';
import 'package:omnispace/models/project.dart';
import 'package:omnispace/services/note_collection_service.dart';
import 'package:omnispace/services/tracker_collection_service.dart';
import 'package:omnispace/services/project_service.dart';
import 'package:omnispace/widgets/main_menu_drawer.dart';

enum CollectionType { all, notes, trackers, projects }

class CollectionsPage extends StatefulWidget {
  const CollectionsPage({Key? key}) : super(key: key);

  @override
  State<CollectionsPage> createState() => _CollectionsPageState();
}

class _CollectionsPageState extends State<CollectionsPage> {
  CollectionType _filter = CollectionType.all;

  final _noteCols    = NoteCollectionService.instance;
  final _trackCols   = TrackerCollectionService.instance;
  final _projService = ProjectService.instance;

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _initAll();
  }

  Future<void> _initAll() async {
    await _noteCols.init();
    await _trackCols.init();
    await _projService.init();
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Build a unified list of all collection types
    final notes    = _noteCols.all.map((c) => _UnifiedCollection.fromNote(c));
    final trackers = _trackCols.all.map((c) => _UnifiedCollection.fromTracker(c));
    final projects = _projService.all.map((p) => _UnifiedCollection.fromProject(p));

    var all = <_UnifiedCollection>[...notes, ...trackers, ...projects];
    if (_filter != CollectionType.all) {
      all = all.where((c) => c.type == _filter).toList();
    }

    return Scaffold(
      drawer: const MainMenuDrawer(),
      appBar: AppBar(
        title: const Text('Collections'),
        actions: [
          PopupMenuButton<CollectionType>(
            icon: const Icon(Icons.filter_list),
            onSelected: (t) => setState(() => _filter = t),
            itemBuilder: (_) => const [
              PopupMenuItem(value: CollectionType.all,      child: Text('All')),
              PopupMenuItem(value: CollectionType.notes,    child: Text('Notes')),
              PopupMenuItem(value: CollectionType.trackers, child: Text('Trackers')),
              PopupMenuItem(value: CollectionType.projects, child: Text('Projects')),
            ],
          ),
        ],
      ),
      body: all.isEmpty
          ? const Center(child: Text('No collections found.'))
          : Padding(
              padding: const EdgeInsets.all(8),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1.2,
                ),
                itemCount: all.length,
                itemBuilder: (ctx, i) {
                  final c = all[i];
                  // pastel background color
                  final hue     = (i * 60) % 360;
                  final bgColor = HSLColor.fromAHSL(1, hue.toDouble(), 0.6, 0.8).toColor();

                  return GestureDetector(
                    onTap: () {
                      // TODO: navigate into this collection’s detail page
                    },
                    child: Card(
                      color: bgColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(c.icon, size: 32, color: Colors.white),
                            const SizedBox(height: 8),
                            Text(
                              c.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${c.count} items',
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createCollection,
        tooltip: 'New Collection',
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _createCollection() async {
    // Step 1: pick a type
    final type = await showModalBottomSheet<CollectionType>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
            leading: const Icon(Icons.collections_bookmark),
            title: const Text('Note Collection'),
            onTap: () => Navigator.pop(context, CollectionType.notes),
          ),
          ListTile(
            leading: const Icon(Icons.folder),
            title: const Text('Tracker Collection'),
            onTap: () => Navigator.pop(context, CollectionType.trackers),
          ),
          ListTile(
            leading: const Icon(Icons.folder_open),
            title: const Text('Project Collection'),
            onTap: () => Navigator.pop(context, CollectionType.projects),
          ),
        ]),
      ),
    );
    if (type == null) return;

    // Step 2: prompt for a name
    final nameCtl = TextEditingController();
    final name = await showDialog<String?>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('New Collection'),
        content: TextField(controller: nameCtl, decoration: const InputDecoration(labelText: 'Name')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, nameCtl.text.trim()), child: const Text('Create')),
        ],
      ),
    );
    if (name == null || name.isEmpty) return;

    final id = DateTime.now().millisecondsSinceEpoch.toString();
    // Persist to the correct service
    switch (type) {
      case CollectionType.notes:
        await _noteCols.create(id: id, name: name, noteIds: []);
        break;
      case CollectionType.trackers:
        await _trackCols.create(id: id, name: name, ownerId: 'self', trackerIds: []);
        break;
      case CollectionType.projects:
        await _projService.save(Project(id: id, title: name, noteIds: []));
        break;
      case CollectionType.all:
        break;
    }

    setState(() {/* rebuilt with new data */});
  }
}

/// A uniform wrapper for the different collection types.
class _UnifiedCollection {
  final String         id;
  final String         name;
  final int            count;
  final IconData       icon;
  final CollectionType type;

  _UnifiedCollection({
    required this.id,
    required this.name,
    required this.count,
    required this.icon,
    required this.type,
  });

  factory _UnifiedCollection.fromNote(NoteCollection c) => _UnifiedCollection(
        id: c.id,
        name: c.name,
        count: c.noteIds.length,
        icon: Icons.collections_bookmark,
        type: CollectionType.notes,
      );

  factory _UnifiedCollection.fromTracker(TrackerCollection c) => _UnifiedCollection(
        id: c.id,
        name: c.name,
        count: c.trackerIds.length,
        icon: Icons.folder,
        type: CollectionType.trackers,
      );

  factory _UnifiedCollection.fromProject(Project p) => _UnifiedCollection(
        id: p.id,
        name: p.title,
        count: p.noteIds.length,
        icon: Icons.folder_open,
        type: CollectionType.projects,
      );
}
