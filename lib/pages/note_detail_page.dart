// File: lib/pages/note_detail_page.dart

import 'dart:io';

import 'package:flutter/material.dart';
import '../models/omni_note.dart';
import '../services/omni_note_service.dart';
import '../services/secure_storage_service.dart';
import '../widgets/main_menu_drawer.dart';
import '../widgets/object_card.dart';
import '../widgets/omni_tracker_selector.dart';
import '../utils/id_generator.dart';

/// Modes for different entry types — still available if you want to
/// switch between text/voice/image/video creation.
enum NoteMode { text, voice, image, video }

class NoteDetailPage extends StatefulWidget {
  final OmniNote? omniNote;
  const NoteDetailPage({Key? key, this.omniNote}) : super(key: key);

  @override
  _NoteDetailPageState createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends State<NoteDetailPage> {
  late OmniNote _note;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleCtl,
      _subtitleCtl,
      _tagsCtl,
      _contentCtl;
  late ZoneTheme _zone;
  bool _lockToggle = false;
  String? _password;

  @override
  void initState() {
    super.initState();
    // If editing existing, use it; otherwise create a fresh one.
    _note = widget.omniNote ??
        OmniNote(
          id: generateId(),
          title: '',
          subtitle: '',
          content: '',
          zone: ZoneTheme.Fusion,
          tags: '',
          colorValue: 0xFFFFFFFF,
          createdAt: DateTime.now(),
          lastUpdated: DateTime.now(),
        );

    _titleCtl = TextEditingController(text: _note.title);
    _subtitleCtl = TextEditingController(text: _note.subtitle);
    _tagsCtl = TextEditingController(text: _note.tags);
    _contentCtl = TextEditingController(text: _note.content);
    _zone = _note.zone;

    _initLockState();
  }

  Future<void> _initLockState() async {
    final pwd =
        await SecureStorageService.instance.read('lock_${_note.id}');
    setState(() {
      _lockToggle = pwd != null;
      _password = pwd;
    });
  }

  @override
  void dispose() {
    _titleCtl.dispose();
    _subtitleCtl.dispose();
    _tagsCtl.dispose();
    _contentCtl.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    if (!_formKey.currentState!.validate()) return;

    _note
      ..title = _titleCtl.text
      ..subtitle = _subtitleCtl.text
      ..tags = _tagsCtl.text
      ..content = _contentCtl.text
      ..zone = _zone
      ..lastUpdated = DateTime.now();

    await OmniNoteService.instance.saveNote(_note);

    // Persist or clear the lock password
    final key = 'lock_${_note.id}';
    if (_lockToggle && _password?.isNotEmpty == true) {
      await SecureStorageService.instance.write(key, _password!);
    } else {
      await SecureStorageService.instance.delete(key);
    }

    Navigator.pop(context);
  }

  Future<void> _onLockToggle(bool on) async {
    if (on) {
      final ctrl = TextEditingController();
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Set Lock Password'),
          content: TextField(
            controller: ctrl,
            decoration: const InputDecoration(labelText: 'Password'),
            obscureText: true,
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel')),
            ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('OK')),
          ],
        ),
      );
      if (ok == true && ctrl.text.isNotEmpty) {
        setState(() {
          _lockToggle = true;
          _password = ctrl.text;
        });
      }
    } else {
      setState(() {
        _lockToggle = false;
        _password = null;
      });
    }
  }

  Future<void> _promptUnlock() async {
    final ctrl = TextEditingController();
    final correct =
        await SecureStorageService.instance.read('lock_${_note.id}') ?? '';
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Unlock Note'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(labelText: 'Password'),
          obscureText: true,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Unlock')),
        ],
      ),
    );
    if (ok == true && ctrl.text == correct) {
      await SecureStorageService.instance
          .delete('lock_${_note.id}');
      setState(() => _lockToggle = false);
    } else if (ok == true) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Wrong password')));
    }
  }

  Future<void> _editCheck() async {
    if (_lockToggle) {
      await _promptUnlock();
      if (_lockToggle) return;
    }
    // Nothing else: form is in-line
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MainMenuDrawer(),
      appBar: AppBar(
        title:
            Text(widget.omniNote == null ? 'New Note' : 'Edit Note'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveNote,
          ),
        ],
      ),
      body: _lockToggle
          ? const Center(
              child: Text('🔒 Note is Locked',
                  style: TextStyle(fontSize: 24)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.stretch,
                children: [
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _titleCtl,
                          decoration:
                              const InputDecoration(labelText: 'Title'),
                          validator: (v) => (v == null ||
                                  v.isEmpty)
                              ? 'Required'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _subtitleCtl,
                          decoration: const InputDecoration(
                              labelText: 'Subtitle'),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _tagsCtl,
                          decoration: const InputDecoration(
                            labelText: 'Tags (comma-separated)',
                            prefixText: '#',
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _contentCtl,
                          decoration:
                              const InputDecoration(labelText: 'Content'),
                          maxLines: 6,
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<ZoneTheme>(
                          value: _zone,
                          decoration:
                              const InputDecoration(labelText: 'Zone'),
                          items: ZoneTheme.values
                              .map((z) => DropdownMenuItem(
                                  value: z, child: Text(z.name)))
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _zone = v!),
                        ),
                        const SizedBox(height: 16),
                        SwitchListTile(
                          title: const Text('Password-Lock'),
                          subtitle: Text(
                              _lockToggle ? 'Locked' : 'Unlocked'),
                          value: _lockToggle,
                          onChanged: _onLockToggle,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // — NEW: Manage all trackers/collections for this note —
                  ElevatedButton.icon(
                    icon: const Icon(Icons.track_changes),
                    label: const Text('Manage Trackers & Collections'),
                    onPressed: () async {
                      // open the shared OmniTrackerSelector,
                      // scoped to this note’s ID
                      await showModalBottomSheet<void>(
                        context: context,
                        isScrollControlled: true,
                        builder: (_) => OmniTrackerSelector(
                            ownerId: _note.id),
                      );
                      // no need to pop; the selector writes straight into the links,
                      // so just rebuild to reflect any new badges, etc.
                      setState(() {});
                    },
                  ),

                  const SizedBox(height: 24),

                  // Read-only preview of the note’s current content/attachments
                  ObjectCard(note: _note),
                ],
              ),
            ),
    );
  }
}
