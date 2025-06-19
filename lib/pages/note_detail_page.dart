// File: lib/pages/note_detail_page.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/omni_note.dart';
import '../models/project.dart';
import '../models/tracker.dart';
import '../widgets/omni_tracker_selector.dart';
import '../services/omni_note_service.dart';
import '../services/project_service.dart';
import '../widgets/main_menu_drawer.dart';
import '../utils/id_generator.dart';

/// Modes for different entry types
enum NoteMode { text, voice, image, video }

class NoteDetailPage extends StatefulWidget {
  final OmniNote? omniNote;
  const NoteDetailPage({Key? key, this.omniNote}) : super(key: key);

  @override
  _NoteDetailPageState createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends State<NoteDetailPage> {
  late OmniNote _note;
  late TextEditingController _titleCtl, _subtitleCtl, _tagsCtl, _contentCtl;
  Project? _selectedProject;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _note = widget.omniNote ?? OmniNote(
      id: generateId(),
      title: '',
      subtitle: '',
      content: '',
      tags: '',
      createdAt: DateTime.now(),
      lastUpdated: DateTime.now(),
    );
    _titleCtl = TextEditingController(text: _note.title);
    _subtitleCtl = TextEditingController(text: _note.subtitle);
    _tagsCtl = TextEditingController(text: _note.tags);
    _contentCtl = TextEditingController(text: _note.content);
    if (_note.projectId != null) {
      _selectedProject = ProjectService.instance.getById(_note.projectId!);
    }
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
    setState(() => _loading = true);
    _note
      ..title = _titleCtl.text.trim()
      ..subtitle = _subtitleCtl.text
      ..tags = _tagsCtl.text
      ..content = _contentCtl.text
      ..lastUpdated = DateTime.now()
      ..projectId = _selectedProject?.id;

    await OmniNoteService.instance.saveNote(_note);
    setState(() => _loading = false);
    Navigator.pop(context);
  }

  Future<void> _selectProject() async {
    final proj = await showDialog<Project?>(
      context: context,
      builder: (_) {
        final all = ProjectService.instance.all;
        return AlertDialog(
          title: const Text('Select Project'),
          content: SizedBox(
            width: 300,
            height: 400,
            child: ListView(
              children: [
                ...all.map((p) => ListTile(
                      title: Text(p.title),
                      selected: p.id == _selectedProject?.id,
                      onTap: () => Navigator.pop(context, p),
                    )),
                ListTile(
                  leading: const Icon(Icons.add),
                  title: const Text('New Project'),
                  onTap: () async {
                    final nameCtl = TextEditingController();
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('New Project'),
                        content: TextField(
                          controller: nameCtl,
                          decoration: const InputDecoration(labelText: 'Name'),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(_, false),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(_, true),
                            child: const Text('Create'),
                          ),
                        ],
                      ),
                    );
                    if (ok == true && nameCtl.text.trim().isNotEmpty) {
                      final p = Project(id: generateId(), title: nameCtl.text.trim());
                      await ProjectService.instance.save(p);
                      Navigator.pop(context, p);
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
    if (proj != null) setState(() => _selectedProject = proj);
  }

  Future<void> _manageTrackers() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => OmniTrackerSelector(ownerId: _note.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MainMenuDrawer(),
      appBar: AppBar(
        title: Text(widget.omniNote == null ? 'New Note' : 'Edit Note'),
        actions: [
          IconButton(icon: const Icon(Icons.folder), tooltip: 'Project', onPressed: _selectProject),
          IconButton(icon: const Icon(Icons.track_changes), tooltip: 'Trackers', onPressed: _manageTrackers),
          IconButton(icon: const Icon(Icons.save), onPressed: _saveNote),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_selectedProject != null)
                    Container(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      padding: const EdgeInsets.all(8),
                      child: Text('Project: ${_selectedProject!.title}'),
                    ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _titleCtl,
                    decoration: const InputDecoration(labelText: 'Title', hintText: 'Untitled'),
                    onTap: () { if (_titleCtl.text.isEmpty) _titleCtl.clear(); },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _subtitleCtl,
                    decoration: const InputDecoration(labelText: 'Subtitle'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _tagsCtl,
                    decoration: const InputDecoration(labelText: 'Tags'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _contentCtl,
                    decoration: const InputDecoration(labelText: 'Content'),
                    maxLines: 6,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Created: ${DateFormat.yMMMd().add_jm().format(_note.createdAt)}   ' 
                    'Updated: ${DateFormat.yMMMd().add_jm().format(_note.lastUpdated)}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
    );
  }
}
