import 'package:flutter/material.dart';

import '../models/tracker.dart';
import '../widgets/object_card.dart';
import '../services/tracker_service.dart';
import 'tracker_forge_page.dart';

/// Read-only view for a [Tracker] with option to pin or edit.
class TrackerViewPage extends StatefulWidget {
  final Tracker tracker;
  const TrackerViewPage({super.key, required this.tracker});

  @override
  State<TrackerViewPage> createState() => _TrackerViewPageState();
}

class _TrackerViewPageState extends State<TrackerViewPage> {
  late Tracker _tracker;

  @override
  void initState() {
    super.initState();
    _tracker = widget.tracker;
  }

  Future<void> _togglePin() async {
    setState(() => _tracker.isPinned = !_tracker.isPinned);
    await TrackerService.instance.save(_tracker);
  }

  Future<void> _edit() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => TrackerForgePage(tracker: _tracker)),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tracker'),
        actions: [
          IconButton(
            icon: Icon(_tracker.isPinned
                ? Icons.push_pin
                : Icons.push_pin_outlined),
            onPressed: _togglePin,
          ),
          IconButton(icon: const Icon(Icons.edit), onPressed: _edit),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: ObjectCard(tracker: _tracker),
      ),
    );
  }
}
