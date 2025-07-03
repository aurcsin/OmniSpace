// File: lib/pages/collections_page.dart

import 'package:flutter/material.dart';

import '../models/note_collection.dart';
import '../services/note_collection_service.dart';
import '../widgets/main_menu_drawer.dart';

class CollectionsPage extends StatefulWidget {
  const CollectionsPage({Key? key}) : super(key: key);

  @override
  State<CollectionsPage> createState() => _CollectionsPageState();
}

class _CollectionsPageState extends State<CollectionsPage> {
  final _collectionSvc = NoteCollectionService.instance;
  List<NoteCollection> _collections = [];
  bool _tooltipVisible = true;

  @override
  void initState() {
    super.initState();
    _loadCollections();
  }

  void _loadCollections() {
    setState(() {
      _collections = _collectionSvc.all;
    });
  }

  Future<void> _showCreateCollectionDialog() async {
    final nameCtl = TextEditingController();
    final name = await showDialog<String?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Note Collection'),
        content: TextField(
          controller: nameCtl,
          decoration: const InputDecoration(labelText: 'Collection Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, nameCtl.text.trim()),
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (name != null && name.isNotEmpty) {
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      await _collectionSvc.create(
        id: id,
        name: name,
        noteIds: [],
      );
      _loadCollections();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Created collection "$name"')),
      );
    }
  }

  void _dismissTooltip() {
    setState(() {
      _tooltipVisible = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MainMenuDrawer(),
      appBar: AppBar(
        title: const Text('Collections'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Help',
            onPressed: () => showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Collections Help'),
                content: const Text(
                  'Here you can group notes into thematic collections.\n'
                  'Tap “+” to create a new collection, then tap a collection to filter your journal.',
                ),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_tooltipVisible)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Card(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                child: ListTile(
                  title: const Text('Here you can group notes into thematic collections.'),
                  trailing: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _dismissTooltip,
                  ),
                ),
              ),
            ),
          Expanded(
            child: _collections.isEmpty
                ? const Center(child: Text('No collections yet. Tap “+” to add one.'))
                : ListView.separated(
                    itemCount: _collections.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final col = _collections[i];
                      return ListTile(
                        title: Text(col.name),
                        subtitle: Text('${col.noteIds.length} notes'),
                        onTap: () {
                          // navigate to filtered JournalPage or callback
                          Navigator.of(context).pop(col.id);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateCollectionDialog,
        tooltip: 'New Collection',
        child: const Icon(Icons.add),
      ),
    );
  }
}
