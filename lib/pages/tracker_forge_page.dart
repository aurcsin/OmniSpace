// File: lib/pages/tracker_forge_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/tracker.dart';
import '../models/tracker_type.dart';
import '../models/omni_note.dart';
import '../services/tracker_service.dart';
import '../services/omni_note_service.dart';
import '../utils/id_generator.dart';

/// Extended Tracker Forge allowing:
///  • recurrence for tasks
///  • select notes to attach to this tracker
///  • create multiple trackers in a batch
class TrackerForgePage extends StatefulWidget {
  final Tracker? tracker;
  final TrackerType? type;

  const TrackerForgePage({super.key, this.tracker, this.type});

  @override
  _TrackerForgePageState createState() => _TrackerForgePageState();
}

class _TrackerForgePageState extends State<TrackerForgePage> {
  final _formKey = GlobalKey<FormState>();
  late TrackerType _type;
  late TextEditingController _titleCtl;
  late TextEditingController _frequencyCtl;
  DateTime? _taskTime;

  // Notes to assimilate
  List<OmniNote> _allNotes = [];
  final Set<String> _selectedNoteIds = {};

  @override
  void initState() {
    super.initState();
    // Listen for notes changes
    OmniNoteService.instance.addListener(_onNotesChanged);
    _allNotes = OmniNoteService.instance.notes;

    _type = widget.tracker?.type ?? widget.type ?? TrackerType.task;
    _titleCtl = TextEditingController(text: widget.tracker?.title ?? '');
    _frequencyCtl = TextEditingController(text: widget.tracker?.frequency ?? '');

    // Initial note list
    _allNotes = OmniNoteService.instance.notes;
    if (widget.tracker != null && widget.tracker!.tags.isNotEmpty) {
      _selectedNoteIds.addAll(widget.tracker!.tags.split(','));
    }
  }

  @override
  void dispose() {
    OmniNoteService.instance.removeListener(_onNotesChanged);
    _titleCtl.dispose();
    _frequencyCtl.dispose();
    super.dispose();
  }

  void _onNotesChanged() {
    setState(() => _allNotes = OmniNoteService.instance.notes);
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_taskTime ?? DateTime.now()),
    );
    if (t != null) {
      setState(() {
        _taskTime = DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
          t.hour,
          t.minute,
        );
      });
    }
  }

  void _toggleNoteSelection(String id) {
    setState(() {
      if (!_selectedNoteIds.remove(id)) _selectedNoteIds.add(id);
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final t = widget.tracker ?? Tracker(id: generateId(), type: _type, title: '');
    t
      ..title = _titleCtl.text.trim()
      ..type = _type
      ..frequency = _type == TrackerType.task ? _frequencyCtl.text.trim() : null
      ..start = _type == TrackerType.event ? _taskTime : null
      ..tags = _selectedNoteIds.join(',');

    await TrackerService.instance.save(t);
    Navigator.of(context).pop(t);
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

  @override
  Widget build(BuildContext context) {
    final typeName = _type.name[0].toUpperCase() + _type.name.substring(1);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tracker == null ? 'New $typeName' : 'Edit $typeName'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.tracker == null)
                DropdownButtonFormField<TrackerType>(
                  value: _type,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: TrackerType.values.map((tt) {
                    return DropdownMenuItem(
                      value: tt,
                      child: Row(
                        children: [Icon(_iconFor(tt)), const SizedBox(width: 8), Text(tt.name)],
                      ),
                    );
                  }).toList(),
                  onChanged: (v) => setState(() => _type = v!),
                ),

              const SizedBox(height: 12),
              TextFormField(
                controller: _titleCtl,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),

              if (_type == TrackerType.task) ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _frequencyCtl,
                  decoration: const InputDecoration(
                      labelText: 'Recurrence (e.g. daily, weekly)'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(_taskTime == null
                          ? 'No time chosen'
                          : DateFormat.jm().format(_taskTime!)),
                    ),
                    TextButton(
                        onPressed: _pickTime, child: const Text('Pick Time')),
                  ],
                ),
              ],

              const SizedBox(height: 24),
              Text('Attach Notes', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ..._allNotes.map((n) {
                return CheckboxListTile(
                  value: _selectedNoteIds.contains(n.id),
                  onChanged: (_) => _toggleNoteSelection(n.id),
                  title: Text(n.title.isEmpty ? '(no title)' : n.title),
                  secondary: const Icon(Icons.note),
                );
              }),

              const SizedBox(height: 24),
              ElevatedButton(onPressed: _save, child: const Text('Save')),
            ],
          ),
        ),
      ),
    );
  }
}
