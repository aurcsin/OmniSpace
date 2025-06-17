import 'package:flutter/material.dart';
import '../models/tracker.dart';
import '../models/tracker_type.dart';
import '../services/tracker_service.dart';
import '../utils/id_generator.dart';

/// Page for editing a tracker. Expects a tracker ID as argument.
class TrackerForgePage extends StatefulWidget {
  final Tracker? tracker;
  final TrackerType? type;

  const TrackerForgePage({super.key, this.tracker, this.type});

  @override
  State<TrackerForgePage> createState() => _TrackerForgePageState();
}

class _TrackerForgePageState extends State<TrackerForgePage> {
  final _formKey = GlobalKey<FormState>();
  late TrackerType _type;
  late TextEditingController _titleCtl;
  late TextEditingController _progressCtl;
  late TextEditingController _frequencyCtl;
  DateTime? _start;

  @override
  void initState() {
    super.initState();
    final tracker = widget.tracker;
    _type = tracker?.type ?? widget.type ?? TrackerType.goal;
    _titleCtl = TextEditingController(text: tracker?.title ?? '');
    _progressCtl = TextEditingController(
        text: tracker?.progress != null ? tracker!.progress!.toString() : '');
    _frequencyCtl = TextEditingController(text: tracker?.frequency ?? '');
    _start = tracker?.start;
  }

  @override
  void dispose() {
    _titleCtl.dispose();
    _progressCtl.dispose();
    _frequencyCtl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final tracker = widget.tracker ??
        Tracker(id: generateId(), type: _type, title: _titleCtl.text);
    tracker
      ..type = _type
      ..title = _titleCtl.text
      ..progress = _type == TrackerType.goal
          ? double.tryParse(_progressCtl.text) ?? tracker.progress
          : null
      ..frequency = _type == TrackerType.task ? _frequencyCtl.text : null
      ..start = _type == TrackerType.event ? _start : null;

    await TrackerService.instance.save(tracker);
    if (mounted) Navigator.pop(context, tracker);
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _start ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() => _start = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tracker == null ? 'New Tracker' : 'Edit Tracker'),
        actions: [IconButton(icon: const Icon(Icons.save), onPressed: _save)],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleCtl,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              if (widget.tracker == null)
                DropdownButtonFormField<TrackerType>(
                  value: _type,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: TrackerType.values
                      .map((t) => DropdownMenuItem(
                            value: t,
                            child: Text(t.name),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _type = v!),
                ),
              if (_type == TrackerType.goal) ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _progressCtl,
                  decoration:
                      const InputDecoration(labelText: 'Progress (0.0–1.0)'),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                ),
              ],
              if (_type == TrackerType.task) ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _frequencyCtl,
                  decoration: const InputDecoration(labelText: 'Frequency'),
                ),
              ],
              if (_type == TrackerType.event) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                          _start == null
                              ? 'No date chosen'
                              : 'Date: ${_start!.toLocal().toIso8601String().split('T').first}'),
                    ),
                    TextButton(
                      onPressed: _pickDate,
                      child: const Text('Pick Date'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
