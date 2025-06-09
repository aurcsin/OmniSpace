// File: lib/pages/note_detail_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';

import '../models/omni_note.dart';
import '../models/zone_theme.dart';
import '../models/zone_theme.dart';
import '../models/zone_theme.dart';
import '../models/zone_theme.dart';
import '../models/zone_theme.dart';
import '../models/tracker_type.dart';
import '../models/tracker.dart';
import '../services/omni_note_service.dart';
import '../services/tracker_service.dart';
import '../widgets/main_menu_drawer.dart';

/// Modes for attachments/demo starting points (not shown in UI)
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
  State<NoteDetailPage> createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends State<NoteDetailPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleCtl;
  late TextEditingController _contentCtl;
  late ZoneTheme _zone;
  final List<File> _imageFiles = [];
  final List<File> _audioFiles = [];
  final List<File> _videoFiles = [];

  @override
  void initState() {
    super.initState();
    _titleCtl = TextEditingController(text: widget.omniNote?.title ?? '');
    _contentCtl = TextEditingController(text: widget.omniNote?.content ?? '');
    _zone = widget.omniNote?.zone ?? ZoneTheme.Fusion;
    // Optional: activate initial mode
    switch (widget.initialMode) {
      case NoteMode.image:
        _pickImage();
        break;
      case NoteMode.video:
        _pickVideo();
        break;
      case NoteMode.voice:
        _recordAudio();
        break;
      default:
        break;
    }
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
          goalBundles: null,
          eventBundles: null,
          taskBundles: null,
          seriesBundles: null,
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

    for (final f in _imageFiles) {
      await OmniNoteService.instance.addImageAttachment(note, f);
    }
    for (final f in _audioFiles) {
      await OmniNoteService.instance.addAudioAttachment(note, f);
    }
    for (final f in _videoFiles) {
      await OmniNoteService.instance.addVideoAttachment(note, f);
    }

    Navigator.pop(context);
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      setState(() => _imageFiles.add(File(picked.path)));
    }
  }

  Future<void> _pickVideo() async {
    final picker = ImagePicker();
    final picked = await picker.pickVideo(source: ImageSource.camera);
    if (picked != null) {
      setState(() => _videoFiles.add(File(picked.path)));
    }
  }

  Future<void> _recordAudio() async {
    final rec = Record();
    if (await rec.hasPermission()) {
      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.m4a';
      await rec.start(path: path);
      await Future.delayed(const Duration(seconds: 5));
      final filePath = await rec.stop();
      if (filePath != null) {
        setState(() => _audioFiles.add(File(filePath)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MainMenuDrawer(),
      appBar: AppBar(
        title: Text(widget.omniNote == null ? 'New Note' : 'Edit Note'),
        actions: [IconButton(icon: const Icon(Icons.save), onPressed: _saveNote)],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleCtl,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _contentCtl,
                decoration: const InputDecoration(labelText: 'Content'),
                maxLines: null,
                keyboardType: TextInputType.multiline,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<ZoneTheme>(
                value: _zone,
                decoration: const InputDecoration(labelText: 'Zone'),
                items: ZoneTheme.values.map((z) {
                  final name = z.toString().split('.').last;
                  return DropdownMenuItem(value: z, child: Text(name));
                }).toList(),
                onChanged: (v) => setState(() => _zone = v!),
              ),
              const SizedBox(height: 12),
              if (_imageFiles.isNotEmpty || _audioFiles.isNotEmpty || _videoFiles.isNotEmpty)
                Wrap(
                  spacing: 8,
                  children: [
                    if (_imageFiles.isNotEmpty) const Icon(Icons.image, size: 20),
                    if (_audioFiles.isNotEmpty) const Icon(Icons.mic, size: 20),
                    if (_videoFiles.isNotEmpty) const Icon(Icons.videocam, size: 20),
                  ],
                ),
              const SizedBox(height: 12),
              for (final type in [
                TrackerType.goal,
                TrackerType.event,
                TrackerType.task,
                TrackerType.series
              ])
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: '${type.name[0].toUpperCase()}${type.name.substring(1)} Link',
                    ),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('— none —')),
                      ...TrackerService.instance.all
                          .where((t) => t.type == type)
                          .map((t) => DropdownMenuItem(value: t.id, child: Text(t.title))),
                      const DropdownMenuItem(value: '__new__', child: Text('Create new…')),
                    ],
                    onChanged: (val) async {
                      if (val == null) return;
                      final note = widget.omniNote;
                      if (val == '__new__') {
                        final newTitle = await showDialog<String>(
                          context: context,
                          builder: (_) => _NamePromptDialog(label: type.name),
                        );
                        if (newTitle != null && newTitle.isNotEmpty && note != null) {
                          final newTracker = Tracker(id: UniqueKey().toString(), type: type, title: newTitle);
                          await TrackerService.instance.create(newTracker);
                          await TrackerService.instance.linkNote(newTracker.id, note.id);
                        }
                      } else if (note != null) {
                        await TrackerService.instance.linkNote(val, note.id);
                      }
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NamePromptDialog extends StatelessWidget {
  final String label;
  const _NamePromptDialog({required this.label});

  @override
  Widget build(BuildContext context) {
    final ctl = TextEditingController();
    return AlertDialog(
      title: Text('New ${label[0].toUpperCase()}${label.substring(1)}'),
      content: TextField(controller: ctl, decoration: InputDecoration(hintText: '$label title')),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(onPressed: () => Navigator.pop(context, ctl.text), child: const Text('Create')),
      ],
    );
  }
}
