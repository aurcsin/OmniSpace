import 'package:flutter/material.dart';
import '../models/tracker.dart';
import '../models/tracker_type.dart';
import '../services/tracker_service.dart';
import '../utils/id_generator.dart';

class TrackerForgePage extends StatefulWidget {
  final Tracker? tracker;
  final TrackerType type;
  const TrackerForgePage({Key? key, this.tracker, required this.type})
      : super(key: key);

  @override
  _TrackerForgePageState createState() => _TrackerForgePageState();
}

class _TrackerForgePageState extends State<TrackerForgePage> {
  late TrackerType _type;
  Tracker? _tracker;
  late TextEditingController _titleCtl;
  late TextEditingController _progressCtl;
  late TextEditingController _frequencyCtl;
  DateTime? _start;
  // For nested sub-items:
  List<Tracker> _all = [];
  final Set<String> _selectedChildren = {};

  @override
  void initState() {
    super.initState();
    _type = widget.type;
    _tracker = widget.tracker;
    _titleCtl = TextEditingController(text: _tracker?.title ?? '');
    _progressCtl = TextEditingController(
        text: _tracker?.progress?.toString() ?? '');
    _frequencyCtl =
        TextEditingController(text: _tracker?.frequency ?? '');
    _start = _tracker?.start;
    _loadAll();
    if (_tracker?.childIds != null) {
      _selectedChildren.addAll(_tracker!.childIds);
    }
  }

  Future<void> _loadAll() async {
    _all = TrackerService.instance
        .all
        .where((t) => widget.tracker == null || t.id != widget.tracker!.id)
        .toList();
    setState(() {});
  }

  @override
  void dispose() {
    _titleCtl.dispose();
    _progressCtl.dispose();
    _frequencyCtl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _start ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (d != null) setState(() => _start = d);
  }

  Future<void> _save() async {
    final t = _tracker ??
        Tracker(id: generateId(), type: _type);
    t
      ..title = _titleCtl.text.trim()
      ..type = _type
      ..progress = _type == TrackerType.goal
          ? double.tryParse(_progressCtl.text) ?? 0
          : null
      ..frequency =
          _type == TrackerType.routine ? _frequencyCtl.text.trim() : null
      ..start = _type == TrackerType.event ? _start : null
      ..childIds = _selectedChildren.toList();

    await TrackerService.instance.save(t);
    Navigator.pop(context, t);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(_tracker == null ? 'New ${_type.name}' : 'Edit ${_type.name}'),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _save),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _titleCtl,
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          const SizedBox(height: 12),
          if (_type == TrackerType.goal) ...[
            TextField(
              controller: _progressCtl,
              decoration: const InputDecoration(
                  labelText: 'Progress (0.0–1.0)'),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
          ],
          if (_type == TrackerType.routine) ...[
            TextField(
              controller: _frequencyCtl,
              decoration: const InputDecoration(labelText: 'Recurrence'),
            ),
          ],
          if (_type == TrackerType.event) ...[
            Row(
              children: [
                Expanded(
                  child: Text(_start == null
                      ? 'No date chosen'
                      : _start!.toLocal().toString().split(' ')[0]),
                ),
                TextButton(
                    onPressed: _pickDate, child: const Text('Pick Date')),
              ],
            ),
          ],
          const Divider(),
          // Sub-items only for Goals & Events
          if (_type == TrackerType.goal || _type == TrackerType.event) ...[
            Text('Sub-items', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ..._all.map((c) {
              return CheckboxListTile(
                title: Text(c.title),
                value: _selectedChildren.contains(c.id),
                onChanged: (_) {
                  setState(() {
                    if (!_selectedChildren.remove(c.id))
                      _selectedChildren.add(c.id);
                  });
                },
              );
            }),
          ],
        ],
      ),
    );
  }
}
