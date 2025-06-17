// File: lib/widgets/omni_tracker_selector.dart

import 'package:flutter/material.dart';
import '../models/tracker.dart';
import '../models/tracker_collection.dart';
import '../models/tracker_type.dart';
import '../services/tracker_service.dart';
import '../services/tracker_collection_service.dart';
import '../pages/tracker_forge_page.dart';

class OmniTrackerSelector extends StatefulWidget {
  /// ID of the object (note, project, etc.) you’re linking trackers into.
  final String ownerId;

  const OmniTrackerSelector({super.key, required this.ownerId});

  @override
  _OmniTrackerSelectorState createState() => _OmniTrackerSelectorState();
}

class _OmniTrackerSelectorState extends State<OmniTrackerSelector> {
  List<Tracker> _allTrackers = [];
  List<TrackerCollection> _allCollections = [];
  Set<String> _linkedTrackerIds = {};

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    await TrackerCollectionService.instance.init();
    await TrackerService.instance.init();
    _allTrackers = TrackerService.instance.all;
    _allCollections = TrackerCollectionService.instance.all;
    _linkedTrackerIds = TrackerService.instance
        .trackerIdsForOwner(widget.ownerId)
        .toSet();
    setState(() {});
  }

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

  Future<void> _toggleLink(String trackerId) async {
    if (_linkedTrackerIds.contains(trackerId)) {
      await TrackerService.instance.unlinkOwner(trackerId, widget.ownerId);
    } else {
      await TrackerService.instance.linkOwner(trackerId, widget.ownerId);
    }
    await _loadAll();
  }

  Future<void> _createNewTracker() async {
    final type = await showModalBottomSheet<TrackerType>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: TrackerType.values.map((t) {
            return ListTile(
              leading: Icon(_iconFor(t)),
              title: Text(t.name),
              onTap: () => Navigator.pop(context, t),
            );
          }).toList(),
        ),
      ),
    );
    if (type != null) {
      final created = await Navigator.of(context).push<Tracker>(
        MaterialPageRoute(builder: (_) => TrackerForgePage(type: type)),
      );
      if (created != null) {
        await TrackerService.instance.linkOwner(created.id, widget.ownerId);
        await _loadAll();
      }
    }
  }

  Future<void> _createNewCollection() async {
    // You can push a CollectionForgePage here,
    // then call _loadAll() afterward.
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        children: [
          // New tracker / collection
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('Create new tracker'),
            onTap: _createNewTracker,
          ),
          ListTile(
            leading: const Icon(Icons.folder_special),
            title: const Text('Create new collection'),
            subtitle: const Text('Group multiple trackers'),
            onTap: _createNewCollection,
          ),
          const Divider(),

          // Collections
          ..._allCollections.map((col) {
            final members = _allTrackers
                .where((t) => col.trackerIds.contains(t.id))
                .toList();
            return ExpansionTile(
              title: Text('${col.name} (${members.length})'),
              initiallyExpanded: true,
              children: members.isEmpty
                  ? [const ListTile(title: Text('— none —'))]
                  : members.map((t) {
                      final linked = _linkedTrackerIds.contains(t.id);
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

          // Ungrouped
          ExpansionTile(
            title: const Text('Ungrouped Trackers'),
            initiallyExpanded: true,
            children: _allTrackers
                .where((t) => _allCollections.every((c) => !c.trackerIds.contains(t.id)))
                .map((t) {
              final linked = _linkedTrackerIds.contains(t.id);
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
