// lib/pages/tracker_forge_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:omnispace/models/tracker.dart';
import 'package:omnispace/models/tracker_type.dart';
import 'package:omnispace/models/omni_note.dart';
import 'package:omnispace/models/tracker_collection.dart';
import 'package:omnispace/services/tracker_service.dart';
import 'package:omnispace/services/omni_note_service.dart';
import 'package:omnispace/services/tracker_collection_service.dart';
import 'package:omnispace/utils/id_generator.dart';
import 'package:omnispace/widgets/help_button.dart';
import 'package:omnispace/widgets/main_menu_drawer.dart';

class TrackerForgePage extends StatefulWidget {
  final Tracker? tracker;
  final TrackerType? type;

  const TrackerForgePage({Key? key, this.tracker, this.type}) : super(key: key);

  @override
  _TrackerForgePageState createState() => _TrackerForgePageState();
}

class _TrackerForgePageState extends State<TrackerForgePage> {
  final _formKey = GlobalKey<FormState>();
  late TrackerType _type;
  late TextEditingController _titleCtl;
  String _recurrence = 'Daily';
  bool _customRecurrence = false;
  late TextEditingController _customRecurrenceCtl;
  DateTime? _taskTime;

  List<OmniNote> _allNotes = [];
  final Set<String> _selectedNoteIds = {};

  List<TrackerCollection> _collections = [];
  String? _selectedCollectionId;

  static const _recurrenceOptions = ['Daily', 'Weekly', 'Monthly', 'Custom'];

  @override
  void initState() {
    super.initState();

    // Load existing notes and collections
    _allNotes = OmniNoteService.instance.notes;
    _collections = TrackerCollectionService.instance.all;

    // Initialize form fields
    _type = widget.tracker?.type ?? widget.type ?? TrackerType.task;
    _titleCtl = TextEditingController(text: widget.tracker?.title ?? '');
    _customRecurrenceCtl =
        TextEditingController(text: widget.tracker?.frequency ?? '');

    // If editing an existing tracker, pre-fill selections
    if (widget.tracker != null) {
      final t = widget.tracker!;

      // Preselect attached notes
      if (t.tags.isNotEmpty) {
        _selectedNoteIds.addAll(t.tags.split(','));
      }

      // Preselect collection if the tracker is in one
      for (final c in _collections) {
        if (c.trackerIds.contains(t.id)) {
          _selectedCollectionId = c.id;
          break;
        }
      }

      // Preselect recurrence option
      final freq = t.frequency;
      if (freq != null && _recurrenceOptions.contains(freq)) {
        _recurrence = freq;
        _customRecurrence = false;
      } else if (freq != null) {
        _recurrence = 'Custom';
        _customRecurrence = true;
        _customRecurrenceCtl.text = freq;
      }

      // Preselect event time
      if (t.type == TrackerType.event) {
        _taskTime = t.start;
      }
    }
  }

  @override
  void dispose() {
    _titleCtl.dispose();
    _customRecurrenceCtl.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime:
          TimeOfDay.fromDateTime(_taskTime ?? DateTime.now()),
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
      if (!_selectedNoteIds.remove(id)) {
        _selectedNoteIds.add(id);
      }
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final tracker = widget.tracker ??
        Tracker(id: generateId(), type: _type, title: '');

    final freq = _type == TrackerType.routine
        ? (_customRecurrence
            ? _customRecurrenceCtl.text.trim()
            : _recurrence)
        : null;

    tracker
      ..title = _titleCtl.text.trim()
      ..type = _type
      ..frequency = freq
      ..start = (_type == TrackerType.event) ? _taskTime : null
      ..tags = _selectedNoteIds.join(',');

    await TrackerService.instance.save(tracker);

    if (_selectedCollectionId != null && _selectedCollectionId!.isNotEmpty) {
      await TrackerCollectionService.instance
          .addToCollection(_selectedCollectionId!, tracker.id);
    }

    Navigator.of(context).pop(tracker);
  }

  IconData _iconFor(TrackerType type) {
    switch (type) {
      case TrackerType.goal:
        return Icons.flag;
      case TrackerType.task:
        return Icons.check_box;
      case TrackerType.event:
        return Icons.event;
      case TrackerType.routine:
        return Icons.repeat;
      case TrackerType.series:
        return Icons.link;
    }
  }

  @override
  Widget build(BuildContext context) {
    final typeName =
        '${_type.name[0].toUpperCase()}${_type.name.substring(1)}';

    return Scaffold(
      drawer: const MainMenuDrawer(),
      appBar: AppBar(
        title: Text(
            widget.tracker == null ? 'New $typeName' : 'Edit $typeName'),
        actions: [
          HelpButton(
            helpTitle: 'Tracker Help',
            helpText: '''
• Name your tracker and choose its type.  
• Routines: pick Daily/Weekly/Monthly or Custom.  
• Custom lets you type any rule.  
• Events: select a time.  
• Attach notes if needed, assign to a cluster, then save.''',
          ),
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Save',
            onPressed: _save,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Type selector (only on create)
              if (widget.tracker == null) ...[
                DropdownButtonFormField<TrackerType>(
                  value: _type,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: TrackerType.values.map((tt) {
                    return DropdownMenuItem(
                      value: tt,
                      child: Row(
                        children: [
                          Icon(_iconFor(tt)),
                          const SizedBox(width: 8),
                          Text(
                              '${tt.name[0].toUpperCase()}${tt.name.substring(1)}'),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (v) => setState(() => _type = v!),
                ),
                const SizedBox(height: 12),
              ],

              // Title
              TextFormField(
                controller: _titleCtl,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Required' : null,
              ),

              // Recurrence (routines)
              if (_type == TrackerType.routine) ...[
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _recurrence,
                  decoration:
                      const InputDecoration(labelText: 'Recurrence'),
                  items: _recurrenceOptions
                      .map((opt) => DropdownMenuItem(
                            value: opt,
                            child: Text(opt),
                          ))
                      .toList(),
                  onChanged: (v) {
                    setState(() {
                      _recurrence = v!;
                      _customRecurrence = (v == 'Custom');
                    });
                  },
                ),
                if (_customRecurrence) ...[
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _customRecurrenceCtl,
                    decoration:
                        const InputDecoration(labelText: 'Custom Rule'),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                ],
              ],

              // Time picker (events)
              if (_type == TrackerType.event) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(_taskTime == null
                          ? 'No time chosen'
                          : DateFormat.jm().format(_taskTime!)),
                    ),
                    TextButton(
                      onPressed: _pickTime,
                      child: const Text('Pick Time'),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 16),

              // Collection selector
              DropdownButtonFormField<String>(
                value: _selectedCollectionId,
                decoration: const InputDecoration(labelText: 'Cluster'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('None')),
                  ..._collections.map((c) => DropdownMenuItem(
                        value: c.id,
                        child: Text(c.name),
                      )),
                ],
                onChanged: (v) =>
                    setState(() => _selectedCollectionId = v),
              ),

              const SizedBox(height: 24),

              // Attach notes
              Text('Attach Notes',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              SizedBox(
                height: 150,
                child: Scrollbar(
                  child: ListView(
                    children: _allNotes.map((n) {
                      return CheckboxListTile(
                        value: _selectedNoteIds.contains(n.id),
                        onChanged: (_) => _toggleNoteSelection(n.id),
                        title: Text(
                            n.title.isEmpty ? '(no title)' : n.title),
                        secondary: const Icon(Icons.note),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
