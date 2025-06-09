import 'package:flutter/material.dart';

import '../models/tracker.dart';
import '../models/tracker_type.dart';
import '../services/tracker_service.dart';

class TrackerEditorPage extends StatefulWidget {
  final Tracker? tracker;
  final TrackerType? type;
  const TrackerEditorPage({this.tracker, this.type, Key? key}) : super(key: key);

  @override
  State<TrackerEditorPage> createState() => _TrackerEditorPageState();
}

class _TrackerEditorPageState extends State<TrackerEditorPage> {
  late TrackerType _type;
  late TextEditingController _titleCtl;
  late TextEditingController _frequencyCtl;
  DateTime? _start;
  List<String> _items = [];
  bool get _isNew => widget.tracker == null;

  @override
  void initState() {
    super.initState();
    _type = widget.tracker?.type ?? widget.type ?? TrackerType.goal;
    _titleCtl = TextEditingController(text: widget.tracker?.title ?? '');
    _frequencyCtl =
        TextEditingController(text: widget.tracker?.frequency ?? '');
    _start = widget.tracker?.start;
    _items = List<String>.from(widget.tracker?.childIds ?? []);
  }

  @override
  void dispose() {
    _titleCtl.dispose();
    _frequencyCtl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _start ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
    if (date != null) {
      setState(() => _start = date);
    }
  }

  Future<void> _save() async {
    final tracker = widget.tracker ??
        Tracker(id: UniqueKey().toString(), type: _type, title: '');
    tracker
      ..title = _titleCtl.text
      ..frequency = _type == TrackerType.task ? _frequencyCtl.text : tracker.frequency
      ..start = _type == TrackerType.event ? _start : tracker.start
      ..childIds = _items
      ..progress = _type == TrackerType.goal ? tracker.progress : tracker.progress;
    await TrackerService.instance.save(tracker);
    Navigator.pop(context);
  }

  Widget _buildTypeSpecificFields() {
    switch (_type) {
      case TrackerType.goal:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text('Stages', style: Theme.of(context).textTheme.titleMedium),
            ReorderableListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (oldIndex < newIndex) newIndex -= 1;
                  final item = _items.removeAt(oldIndex);
                  _items.insert(newIndex, item);
                });
              },
              children: [
                for (int i = 0; i < _items.length; i++)
                  ListTile(
                    key: ValueKey('stage_$i'),
                    title: Text(_items[i]),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => setState(() => _items.removeAt(i)),
                    ),
                  ),
              ],
            ),
            TextButton(
              onPressed: () async {
                final ctl = TextEditingController();
                final name = await showDialog<String>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('New Stage'),
                    content: TextField(controller: ctl),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, ctl.text),
                        child: const Text('Add'),
                      ),
                    ],
                  ),
                );
                if (name != null && name.isNotEmpty) {
                  setState(() => _items.add(name));
                }
              },
              child: const Text('Add Stage'),
            ),
          ],
        );
      case TrackerType.task:
        return TextField(
          controller: _frequencyCtl,
          decoration: const InputDecoration(labelText: 'Frequency'),
        );
      case TrackerType.event:
        return Row(
          children: [
            Expanded(
              child: Text(_start == null
                  ? 'No date selected'
                  : _start!.toLocal().toString().split(' ').first),
            ),
            TextButton(onPressed: _pickDate, child: const Text('Pick Date')),
          ],
        );
      case TrackerType.series:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ReorderableListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (oldIndex < newIndex) newIndex -= 1;
                  final item = _items.removeAt(oldIndex);
                  _items.insert(newIndex, item);
                });
              },
              children: [
                for (int i = 0; i < _items.length; i++)
                  ListTile(
                    key: ValueKey('item_$i'),
                    title: Text(_items[i]),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => setState(() => _items.removeAt(i)),
                    ),
                  ),
              ],
            ),
            TextButton(
              onPressed: () async {
                final ctl = TextEditingController();
                final id = await showDialog<String>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Add Item ID'),
                    content: TextField(controller: ctl),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, ctl.text),
                        child: const Text('Add'),
                      ),
                    ],
                  ),
                );
                if (id != null && id.isNotEmpty) {
                  setState(() => _items.add(id));
                }
              },
              child: const Text('Add Item'),
            ),
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isNew ? 'New Tracker' : 'Edit Tracker'),
        actions: [IconButton(icon: const Icon(Icons.save), onPressed: _save)],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<TrackerType>(
              value: _type,
              decoration: const InputDecoration(labelText: 'Type'),
              items: TrackerType.values
                  .map((t) => DropdownMenuItem(value: t, child: Text(t.name)))
                  .toList(),
              onChanged: (t) => setState(() => _type = t!),
            ),
            TextField(
              controller: _titleCtl,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            _buildTypeSpecificFields(),
          ],
        ),
      ),
    );
  }
}
