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
    if (note == null || val == null) return;
    if (val == '__new__') {
      final newTitle = await showDialog<String>(
        context: context,
        builder: (_) => _NamePromptDialog(label: type.name),
      );
      if (newTitle != null && newTitle.isNotEmpty) {
        final newTracker = Tracker(
          id: generateId(),
          type: type,
          title: newTitle,
        );
        await TrackerService.instance.create(newTracker);
        await TrackerService.instance.linkNote(newTracker.id, note.id);
      }
    } else {
      await TrackerService.instance.linkNote(val, note.id);
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

/// Dialog to prompt for a new Tracker title.
class _NamePromptDialog extends StatelessWidget {
  final String label;
  const _NamePromptDialog({required this.label});

  @override
  Widget build(BuildContext context) {
    final ctl = TextEditingController();
    return AlertDialog(
      title: Text('New ${label[0].toUpperCase()}${label.substring(1)}'),
      content: TextField(
        controller: ctl,
        decoration: InputDecoration(hintText: '$label title'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, ctl.text),
          child: const Text('Create'),
        ),
      ],
    );
  }
}
