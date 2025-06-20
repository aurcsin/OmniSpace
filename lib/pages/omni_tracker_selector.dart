// File: lib/widgets/omni_tracker_selector.dart

import 'package:flutter/material.dart';
import '../models/tracker.dart';
import '../models/tracker_collection.dart';
import '../models/tracker_type.dart';
import '../services/tracker_service.dart';
import '../services/tracker_collection_service.dart';
import '../pages/tracker_forge_page.dart';

/// A sheet for linking individual trackers or entire collections
/// into one “owner” (e.g. a note).
class OmniTrackerSelector extends StatefulWidget {
  /// ID of the object (note, project, etc.) you’re linking trackers into.
  final String ownerId;

  const OmniTrackerSelector({Key? key, required this.ownerId}) : super(key: key);

  @override
  _OmniTrackerSelectorState createState() => _OmniTrackerSelectorState();
}

class _OmniTrackerSelectorState extends State<OmniTrackerSelector> {
  List<Tracker> _allTrackers = [];
  List<TrackerCollection> _allCollections = [];
  Set<String> _linkedIds = {};

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    // TrackerService.all is synchronous; collections comes back as a Future
    _allTrackers = TrackerService.instance.all;
    _allCollections = await TrackerCollectionService.instance.all;
    _linkedIds = TrackerService.instance.linkedTo(widget.ownerId).toSet();
    setState(() {});
  }

  IconData _iconFor(TrackerType type) {
    switch (type) {
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

  Future<void> _toggleLink(String tid) async {
    if (_linkedIds.contains(tid)) {
      await TrackerService.instance.unlinkNote(tid, widget.ownerId);
    } else {
      await TrackerService.instance.linkNote(tid, widget.ownerId);
    }
    await _reload();
  }

  Future<void> _createNewTracker() async {
    // Pick a tracker type
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
      // Forge a new tracker
      final created = await Navigator.of(context).push<Tracker>(
        MaterialPageRoute(builder: (_) => TrackerForgePage(type: type)),
      );
      if (created != null) {
        // Link it immediately
        await TrackerService.instance.linkNote(created.id, widget.ownerId);
        await _reload();
      }
    }
  }

  Future<void> _createNewCollection() async {
    final nameCtl = TextEditingController();
    final selectedForNew = Set<String>.from(_linkedIds);

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Tracker Collection'),
        content: StatefulBuilder(
          builder: (ctx2, setSt) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtl,
                  decoration: const InputDecoration(labelText: 'Collection Name'),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 200,
                  width: double.maxFinite,
                  child: ListView(
                    children: _allTrackers.map((t) {
                      final isChecked = selectedForNew.contains(t.id);
                      return CheckboxListTile(
                        value: isChecked,
                        secondary: Icon(_iconFor(t.type)),
                        title: Text(t.title),
                        onChanged: (_) => setSt(() {
                          if (isChecked)
                            selectedForNew.remove(t.id);
                          else
                            selectedForNew.add(t.id);
                        }),
                      );
                    }).toList(),
                  ),
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final name = nameCtl.text.trim();
              if (name.isNotEmpty) {
                final newCol = TrackerCollection(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: name,
                  ownerId: widget.ownerId,
                  trackerIds: selectedForNew.toList(),
                );
                await TrackerCollectionService.instance.save(newCol);
              }
              Navigator.pop(ctx);
              await _reload();
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // Create new tracker
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('Create new tracker'),
            onTap: _createNewTracker,
          ),

          // Create new collection
          ListTile(
            leading: const Icon(Icons.folder_special),
            title: const Text('Create new collection'),
            subtitle: const Text('Group multiple trackers'),
            onTap: _createNewCollection,
          ),

          const Divider(),

          // Existing Collections
          ..._allCollections.map((col) {
            final members = _allTrackers.where((t) => col.trackerIds.contains(t.id)).toList();
            return ExpansionTile(
              title: Text('${col.name} (${members.length})'),
              initiallyExpanded: true,
              children: members.isEmpty
                  ? [const ListTile(title: Text('— none —'))]
                  : members.map((t) {
                      final linked = _linkedIds.contains(t.id);
                      return CheckboxListTile(
                        value: linked,
                        onChanged: (_) => _toggleLink(t.id),
                        secondary: Icon(_iconFor(t.type)),
                        title: Text(t.title),
                      );
                    }).toList(),
            );
          }),

          const Divider(),

          // Ungrouped Trackers
          ExpansionTile(
            title: const Text('Ungrouped Trackers'),
            initiallyExpanded: true,
            children: _allTrackers
                .where((t) => _allCollections.every((c) => !c.trackerIds.contains(t.id)))
                .map((t) {
                  final linked = _linkedIds.contains(t.id);
                  return CheckboxListTile(
                    value: linked,
                    onChanged: (_) => _toggleLink(t.id),
                    secondary: Icon(_iconFor(t.type)),
                    title: Text(t.title),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }
}
