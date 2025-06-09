// File: lib/pages/note_detail_page.dart

import 'package:flutter/material.dart';

import '../models/omni_note.dart';
import '../models/tracker_type.dart';
import '../models/tracker.dart';
import '../services/omni_note_service.dart';
import '../services/tracker_service.dart';
import '../widgets/main_menu_drawer.dart';

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
  final Map<TrackerType, List<Tracker>> _pendingLinks = {
    for (var t in TrackerType.values) t: <Tracker>[],
  };
  late TextEditingController _titleCtl;
  late TextEditingController _contentCtl;
  late ZoneTheme _zone;

  @override
  void initState() {
    super.initState();
    _titleCtl = TextEditingController(text: widget.omniNote?.title ?? '');
    _contentCtl = TextEditingController(text: widget.omniNote?.content ?? '');
    _zone = widget.omniNote?.zone ?? ZoneTheme.Fusion;
    _initLinked();
  }

  @override
  void dispose() {
    _titleCtl.dispose();
    _contentCtl.dispose();
    super.dispose();
  }

  void _initLinked() {
    final note = widget.omniNote;
    if (note == null) return;
    final ids = TrackerService.instance.linkedTo(note.id);
    for (final id in ids) {
      final matches =
          TrackerService.instance.all.where((t) => t.id == id);
      if (matches.isNotEmpty) {
        final tracker = matches.first;
        _pendingLinks[tracker.type]!.add(tracker);
      }
    }
  }

  Future<void> _saveNote() async {
    if (!_formKey.currentState!.validate()) return;
    final note = widget.omniNote ?? OmniNote(
          id: UniqueKey().toString(),
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
    for (final entry in _pendingLinks.entries) {
      for (final tracker in entry.value) {
        await TrackerService.instance.linkNote(tracker.id, note.id);
      }
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MainMenuDrawer(),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
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
              // —— LINK TO TRACKERS ——
              const SizedBox(height: 12),
              for (final type in TrackerType.values)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: _buildTrackerField(type),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrackerField(TrackerType type) {
    final selected = _pendingLinks[type]!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 4,
          children: [
            for (final t in selected)
              InputChip(
                label: Text(t.title),
                onDeleted: () async {
                  setState(() => selected.remove(t));
                  if (widget.omniNote != null) {
                    await TrackerService.instance.unlinkNote(t.id, widget.omniNote!.id);
                  }
                },
              ),
          ],
        ),
        Autocomplete<Tracker>(
          optionsBuilder: (text) {
            final q = text.text.toLowerCase();
            final opts = TrackerService.instance.ofType(type);
            if (q.isEmpty) return opts;
            return opts.where((t) => t.title.toLowerCase().contains(q));
          },
          displayStringForOption: (t) => t.title,
          onSelected: (tracker) async {
            if (!selected.contains(tracker)) {
              setState(() => selected.add(tracker));
              if (widget.omniNote != null) {
                await TrackerService.instance.linkNote(tracker.id, widget.omniNote!.id);
              }
            }
          },
          fieldViewBuilder: (context, ctl, focus, onSubmit) {
            return TextField(
              controller: ctl,
              focusNode: focus,
              decoration: InputDecoration(
                labelText: '${type.name[0].toUpperCase()}${type.name.substring(1)} Link',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () async {
                    final title = ctl.text.trim();
                    if (title.isEmpty) return;
                    final newTracker = Tracker(
                      id: UniqueKey().toString(),
                      type: type,
                      title: title,
                    );
                    await TrackerService.instance.create(newTracker);
                    setState(() => selected.add(newTracker));
                    if (widget.omniNote != null) {
                      await TrackerService.instance.linkNote(newTracker.id, widget.omniNote!.id);
                    }
                    ctl.clear();
                  },
                ),
              ),
              onSubmitted: (_) {},
            );
          },
        ),
      ],
    );
  }
}
