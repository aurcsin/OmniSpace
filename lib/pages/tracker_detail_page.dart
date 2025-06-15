import 'package:flutter/material.dart';
import '../models/tracker.dart';

/// Simple page showing details for a [Tracker].
class TrackerDetailPage extends StatefulWidget {
  final Tracker tracker;
  const TrackerDetailPage({required this.tracker, super.key});

  @override
  State<TrackerDetailPage> createState() => _TrackerDetailPageState();
}

class _TrackerDetailPageState extends State<TrackerDetailPage> {
  late TextEditingController _titleCtl;
  late Tracker _tracker;

  @override
  void initState() {
    super.initState();
    _tracker = widget.tracker;
    _titleCtl = TextEditingController(text: _tracker.title);
  }

  @override
  void dispose() {
    _titleCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_tracker.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleCtl,
              decoration: const InputDecoration(labelText: 'Title'),
              onChanged: (value) => setState(() => _tracker.title = value),
            ),
            const SizedBox(height: 12),
            Text('Type: ${_tracker.type.name}'),
            if (_tracker.progress != null)
              Text('Progress: ${(_tracker.progress! * 100).round()}%'),
            if (_tracker.frequency != null) Text('Frequency: ${_tracker.frequency}'),
            if (_tracker.start != null)
              Text('Start: ${_tracker.start!.toLocal()}'),
            if (_tracker.childIds.isNotEmpty)
              Text('Children: ${_tracker.childIds.join(', ')}'),
          ],
        ),
      ),
    );
  }
}
