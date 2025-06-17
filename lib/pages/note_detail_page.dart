// File: lib/pages/note_detail_page.dart

import 'package:flutter/material.dart';

import '../models/omni_note.dart';
import '../models/tracker_type.dart';
import '../models/tracker.dart';
import '../services/omni_note_service.dart';
import '../services/tracker_service.dart';
import '../widgets/main_menu_drawer.dart';
import '../utils/id_generator.dart';

/// Modes for the detail page: text, voice, image, or video.
enum NoteMode { text, voice, image, video }

class NoteDetailPage extends StatefulWidget {
  final OmniNote? omniNote;
  final NoteMode initialMode;

  const NoteDetailPage({
    this.omniNote,
    this.initialMode = NoteMode.text,
    super.key,
  });

  @override
  _NoteDetailPageState createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends State<NoteDetailPage> {
  final _formKey = GlobalKey<FormState>();
  late NoteMode _mode;
  late TextEditingController _titleCtl;
  late TextEditingController _contentCtl;
  late ZoneTheme _zone;

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
    _titleCtl = TextEditingController(text: widget.omniNote?.title ?? '');
    _contentCtl = TextEditingController(text: widget.omniNote?.content ?? '');
    _zone = widget.omniNote?.zone ?? ZoneTheme.Fusion;
  }

  @override
  void dispose() {
    _titleCtl.dispose();
    _contentCtl.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    if (!_formKey.currentState!.validate()) return;
    final note = widget.omniNote ?? OmniNote(
          id: generateId(),
          title: _titleCtl.text,
          subtitle: '',
          content: _contentCtl.text,
          zone: _zone,
          tags: '',
          colorValue: 0xFFFFFFFF,
          mood: null,
          direction: null,
          projectId: null,
          recommendedTag: null,
          seriesId: null,
          attachments: [],
          tasks: null,
          goals: null,
          events: null,
          createdAt: DateTime.now(),
          lastUpdated: DateTime.now(),
          isPinned: false,
        );
    note
      ..title = _titleCtl.text
      ..content = _contentCtl.text
      ..zone = _zone
      ..lastUpdated = DateTime.now();
    await OmniNoteService.instance.saveNote(note);
    Navigator.pop(context);
  }

  Future<void> _handleTrackerChange(TrackerType type, String? val) async {
    final note = widget.omniNote;
    if (val == null) return;
    if (val == '__new__') {
      final newTracker = await showDialog<Tracker>(
        context: context,
        builder: (_) => _QuickTrackerDialog(type: type),
      );
      if (newTracker != null) {
        await TrackerService.instance.create(newTracker);
        if (note != null) {
          await TrackerService.instance.linkNote(newTracker.id, note.id);
        }
      }
    } else {
      if (note != null) {
        await TrackerService.instance.linkNote(val, note.id);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MainMenuDrawer(),
      appBar: AppBar(
        title: Text(widget.omniNote == null ? 'New Note' : 'Edit Note'),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _saveNote),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title
              TextFormField(
                controller: _titleCtl,
                decoration: const InputDecoration(labelText: 'Title'),
              ),

              const SizedBox(height: 12),

              // Content
              TextFormField(
                controller: _contentCtl,
                decoration: const InputDecoration(labelText: 'Content'),
                maxLines: null,
                keyboardType: TextInputType.multiline,
              ),

              const SizedBox(height: 12),

              // Zone selector
              DropdownButtonFormField<ZoneTheme>(
                value: _zone,
                decoration: const InputDecoration(labelText: 'Zone'),
                items: ZoneTheme.values.map((z) {
                  final name = z.toString().split('.').last;
                  return DropdownMenuItem(
                    value: z,
                    child: Text(name),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _zone = v!),
              ),

              // Mode indicator (uses _mode)
              const SizedBox(height: 12),
              Text(
                'Mode: ${_mode.name[0].toUpperCase()}${_mode.name.substring(1)}',
                style: Theme.of(context).textTheme.titleMedium,
              ),

              // Linked trackers display
              if (widget.omniNote != null) ...[
                const SizedBox(height: 12),
                Text('Linked Trackers',
                    style: Theme.of(context).textTheme.titleMedium),
                Wrap(
                  spacing: 8,
                  children: TrackerService.instance
                      .trackersForNote(widget.omniNote!.id)
                      .map((t) => Chip(label: Text(t.title)))
                      .toList(),
                ),
              ],

              // —— LINK TO TRACKERS ——
              const SizedBox(height: 12),
              for (final type in TrackerType.values)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText:
                          '${type.name[0].toUpperCase()}${type.name.substring(1)} Link',
                    ),
                    value: null,
                    items: [
                      const DropdownMenuItem(
                          value: null, child: Text('— none —')),
                      ...TrackerService.instance.all
                          .where((t) => t.type == type)
                          .map((t) => DropdownMenuItem(
                                value: t.id,
                                child: Text(t.title),
                              )),
                      const DropdownMenuItem(
                        value: '__new__',
                        child: Text('Create new…'),
                      ),
                    ],
                    onChanged: (val) => _handleTrackerChange(type, val),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dialog for quickly creating a tracker of a specific type.
class _QuickTrackerDialog extends StatefulWidget {
  final TrackerType type;
  const _QuickTrackerDialog({required this.type});

  @override
  State<_QuickTrackerDialog> createState() => _QuickTrackerDialogState();
}

class _QuickTrackerDialogState extends State<_QuickTrackerDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleCtl;
  late TextEditingController _progressCtl;
  late TextEditingController _frequencyCtl;
  DateTime? _start;

  @override
  void initState() {
    super.initState();
    _titleCtl = TextEditingController();
    _progressCtl = TextEditingController();
    _frequencyCtl = TextEditingController();
  }

  @override
  void dispose() {
    _titleCtl.dispose();
    _progressCtl.dispose();
    _frequencyCtl.dispose();
    super.dispose();
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
    final typeName =
        '${widget.type.name[0].toUpperCase()}${widget.type.name.substring(1)}';
    return AlertDialog(
      title: Text('New $typeName'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleCtl,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              if (widget.type == TrackerType.goal) ...[
                const SizedBox(height: 8),
                TextFormField(
                  controller: _progressCtl,
                  decoration:
                      const InputDecoration(labelText: 'Progress (0.0–1.0)'),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                ),
              ],
              if (widget.type == TrackerType.task) ...[
                const SizedBox(height: 8),
                TextFormField(
                  controller: _frequencyCtl,
                  decoration: const InputDecoration(labelText: 'Frequency'),
                ),
              ],
              if (widget.type == TrackerType.event) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _start == null
                            ? 'No date chosen'
                            : 'Date: ${_start!.toLocal().toIso8601String().split('T').first}',
                      ),
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
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            final tracker = Tracker(
              id: generateId(),
              type: widget.type,
              title: _titleCtl.text,
              progress: widget.type == TrackerType.goal
                  ? double.tryParse(_progressCtl.text)
                  : null,
              frequency:
                  widget.type == TrackerType.task ? _frequencyCtl.text : null,
              start: widget.type == TrackerType.event ? _start : null,
            );
            Navigator.pop(context, tracker);
          },
          child: const Text('Create'),
        ),
      ],
    );
  }
}
