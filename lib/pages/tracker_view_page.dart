// File: lib/pages/tracker_view_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/tracker.dart';
import '../models/tracker_type.dart';
import '../services/tracker_service.dart';
import '../services/omni_note_service.dart';
import '../widgets/main_menu_drawer.dart';
import 'tracker_forge_page.dart';
import 'note_view_page.dart';

class TrackerViewPage extends StatefulWidget {
  final Tracker tracker;
  const TrackerViewPage({Key? key, required this.tracker}) : super(key: key);

  @override
  State<TrackerViewPage> createState() => _TrackerViewPageState();
}

class _TrackerViewPageState extends State<TrackerViewPage> {
  late Tracker _tracker;

  @override
  void initState() {
    super.initState();
    // reload in case it changed elsewhere
    _tracker =
        TrackerService.instance.byId(widget.tracker.id) ?? widget.tracker;
  }

  Future<void> _edit() async {
    final updated = await Navigator.of(context).push<Tracker>(
      MaterialPageRoute(builder: (_) => TrackerForgePage(tracker: _tracker)),
    );
    if (updated != null) setState(() => _tracker = updated);
  }

  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Tracker?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(_, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(_, true), child: const Text('Delete')),
        ],
      ),
    );
    if (ok == true) {
      await TrackerService.instance.deleteTracker(_tracker.id);
      Navigator.of(context).pop();
    }
  }

  Widget _buildScheduling() {
    if (_tracker.type == TrackerType.event ||
        _tracker.type == TrackerType.routine) {
      final start = _tracker.start;
      final freq = _tracker.frequency;
      return ListTile(
        leading: const Icon(Icons.calendar_today),
        title: Text(start != null
            ? DateFormat.yMMMd().add_jm().format(start)
            : 'No start date'),
        subtitle: (freq?.isNotEmpty ?? false)
            ? Text('Repeats: $freq')
            : const Text('One-off'),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildSubTrackers() {
    if (_tracker.childIds.isEmpty) return const SizedBox.shrink();
    return ExpansionTile(
      leading: const Icon(Icons.subdirectory_arrow_right),
      title: const Text('Sub-items'),
      children: _tracker.childIds.map((sid) {
        final sub = TrackerService.instance.byId(sid);
        if (sub == null) return const SizedBox.shrink();
        return CheckboxListTile(
          value: sub.isCompleted,
          title: Text(sub.title),
          onChanged: (_) async {
            sub.toggleComplete();
            await sub.save();
            setState(() => _tracker = TrackerService.instance.byId(_tracker.id)!);
          },
        );
      }).toList(),
    );
  }

  Widget _buildLinkedNotes() {
    if (_tracker.linkedNoteIds.isEmpty) return const SizedBox.shrink();
    return ExpansionTile(
      leading: const Icon(Icons.note),
      title: const Text('Linked Notes'),
      children: _tracker.linkedNoteIds.map((nid) {
        final note = OmniNoteService.instance.getNoteById(nid);
        if (note == null) return const SizedBox.shrink();
        return ListTile(
          title: Text(note.title.isNotEmpty ? note.title : '(No Title)'),
          subtitle: Text(DateFormat.yMMMd().format(note.createdAt)),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => NoteViewPage(note: note)),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLinkedTrackers() {
    if (_tracker.linkedTrackerIds.isEmpty) return const SizedBox.shrink();
    return ExpansionTile(
      leading: const Icon(Icons.link),
      title: const Text('Connected Trackers'),
      children: _tracker.linkedTrackerIds.map((tid) {
        final t = TrackerService.instance.byId(tid);
        if (t == null) return const SizedBox.shrink();
        return ListTile(
          title: Text(t.title),
          subtitle: Text(t.type.name.toUpperCase()),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => TrackerViewPage(tracker: t)),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final icon = {
      TrackerType.goal: Icons.flag,
      TrackerType.event: Icons.event,
      TrackerType.routine: Icons.repeat,
      TrackerType.series: Icons.collections,
    }[_tracker.type]!;

    return Scaffold(
      drawer: const MainMenuDrawer(),
      appBar: AppBar(
        title: Text(_tracker.title),
        actions: [
          IconButton(icon: const Icon(Icons.edit), onPressed: _edit),
          IconButton(icon: const Icon(Icons.delete), onPressed: _delete),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: Icon(icon, size: 32),
            title: Text(_tracker.title, style: const TextStyle(fontSize: 20)),
            subtitle: Text(_tracker.type.name.toUpperCase()),
          ),
          const Divider(),
          _buildScheduling(),
          const Divider(),
          _buildSubTrackers(),
          const Divider(),
          _buildLinkedNotes(),
          const Divider(),
          _buildLinkedTrackers(),
        ],
      ),
    );
  }
}
