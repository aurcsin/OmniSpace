// File: lib/pages/tracker_detail_page.dart

import 'package:flutter/material.dart';
import '../models/tracker.dart';

/// Simple page showing details for a [Tracker].
class TrackerDetailPage extends StatefulWidget {
  final Tracker tracker;
  const TrackerDetailPage({Key? key, required this.tracker}) : super(key: key);

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
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(_tracker.title.isNotEmpty ? _tracker.title : '(No Title)'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Editable title
            TextField(
              controller: _titleCtl,
              decoration: const InputDecoration(labelText: 'Title'),
              onChanged: (value) {
                setState(() {
                  _tracker.title = value;
                });
              },
            ),
            const SizedBox(height: 12),
            // Type
            Text(
              'Type: ${_tracker.type.name.toUpperCase()}',
              style: textTheme.bodyMedium,
            ),
            // Progress (for goals)
            if (_tracker.progress != null)
              Text(
                'Progress: ${(_tracker.progress! * 100).round()}%',
                style: textTheme.bodyMedium,
              ),
            // Frequency (for routines/tasks)
            if (_tracker.frequency != null && _tracker.frequency!.isNotEmpty)
              Text(
                'Frequency: ${_tracker.frequency}',
                style: textTheme.bodyMedium,
              ),
            // Start date (for events)
            if (_tracker.start != null)
              Text(
                'Start: ${_tracker.start!.toLocal()}',
                style: textTheme.bodyMedium,
              ),
            // Children (sub-trackers)
            if (_tracker.childIds.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Sub-items:',
                style: textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                children: _tracker.childIds
                    .map((cid) => Chip(label: Text(cid)))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
