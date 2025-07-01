// File: lib/pages/collections_page.dart

import 'package:flutter/material.dart';

import '../models/tracker_collection.dart';
import '../services/tracker_collection_service.dart';
import '../widgets/main_menu_drawer.dart';

class CollectionsPage extends StatefulWidget {
  const CollectionsPage({Key? key}) : super(key: key);

  @override
  State<CollectionsPage> createState() => _CollectionsPageState();
}

class _CollectionsPageState extends State<CollectionsPage> {
  final svc = TrackerCollectionService.instance;

  @override
  Widget build(BuildContext context) {
    final cols = svc.all;
    return Scaffold(
      drawer: const MainMenuDrawer(),
      appBar: AppBar(title: const Text('Collections')),
      body: ListView.separated(
        itemCount: cols.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (_, i) {
          final c = cols[i];
          return ListTile(
            leading: const Icon(Icons.folder),
            title: Text(c.name),
            subtitle: Text('${c.trackerIds.length} items'),
            onTap: () {
              // TODO: push detail/edit page if desired
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'New Collection',
        child: const Icon(Icons.create_new_folder),
        onPressed: () async {
          final nameCtl = TextEditingController();
          final ok = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('New Collection'),
              content: TextField(
                controller: nameCtl,
                decoration:
                    const InputDecoration(labelText: 'Collection Name'),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Create'),
                ),
              ],
            ),
          );
          if (ok == true && nameCtl.text.trim().isNotEmpty) {
            await svc.create(
              name: nameCtl.text.trim(),
              ownerId: '',          // TODO: replace with actual user ID
              trackerIds: [],       // start empty
            );
            setState(() {});
          }
        },
      ),
    );
  }
}
