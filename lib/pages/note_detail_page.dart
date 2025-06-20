// File: lib/pages/note_detail_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/omni_note.dart';
import '../models/project.dart';
import '../models/zone_theme.dart';
import '../services/omni_note_service.dart';
import '../services/project_service.dart';
import '../widgets/main_menu_drawer.dart';
import '../widgets/omni_tracker_selector.dart';
import '../utils/id_generator.dart';

class NoteDetailPage extends StatefulWidget {
  final OmniNote? omniNote;
  const NoteDetailPage({Key? key, this.omniNote}) : super(key: key);

  @override
  State<NoteDetailPage> createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends State<NoteDetailPage> {
  late OmniNote _note;
  late TextEditingController _titleCtl,
      _subtitleCtl,
      _tagsCtl,
      _contentCtl;
  Project? _selectedProject;
  bool _loading = false;
  bool _locked = false;
  bool _starred = false;

  @override
  void initState() {
    super.initState();

    if (widget.omniNote != null) {
      _note = widget.omniNote!;
    } else {
      _note = OmniNote(
        id: generateId(),
        title: '',
        subtitle: '',
        content: '',
        tags: '',
        zone: ZoneTheme.Fusion,
        colorValue: 0xFFFFFFFF,
        createdAt: DateTime.now(),
        lastUpdated: DateTime.now(),
      );
      _note.isStarred = false;
      _note.isLocked = false;
    }

    _locked = _note.isLocked;
    _starred = _note.isStarred;

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

  Future<void> _save() async {
    setState(() => _loading = true);

    _note
      ..title = _titleCtl.text.trim()
      ..subtitle = _subtitleCtl.text.trim()
      ..tags = _tagsCtl.text.trim()
      ..content = _contentCtl.text
      ..lastUpdated = DateTime.now()
      ..projectId = _selectedProject?.id
      ..isLocked = _locked
      ..isStarred = _starred;

    await OmniNoteService.instance.saveNote(_note);

    setState(() => _loading = false);
    Navigator.of(context).pop();
  }

  void _toggleStar() {
    setState(() => _starred = !_starred);
  }

  void _toggleLock() {
    setState(() => _locked = !_locked);
  }

  Future<void> _selectProject() async {
    final proj = await showDialog<Project?>(
      context: context,
      builder: (ctx) {
        final projects = ProjectService.instance.all;
        return AlertDialog(
          title: const Text('Select Project'),
          content: SizedBox(
            width: 300,
            height: 400,
            child: ListView(
              children: [
                ...projects.map((p) => ListTile(
                      title: Text(p.title),
                      selected: p.id == _selectedProject?.id,
                      onTap: () => Navigator.pop(ctx, p),
                    )),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.add),
                  title: const Text('New Project'),
                  onTap: () => Navigator.pop(ctx, null),
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

  void _delete() async {
    await OmniNoteService.instance.deletePermanent([_note.id]);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MainMenuDrawer(),
      appBar: AppBar(
        title: Text(widget.omniNote == null ? 'New Note' : 'Edit Note'),
        actions: [
          IconButton(
            icon: Icon(_starred ? Icons.star : Icons.star_border),
            tooltip: _starred ? 'Unstar' : 'Star',
            onPressed: _toggleStar,
          ),
          IconButton(
            icon: Icon(_locked ? Icons.lock : Icons.lock_open),
            tooltip: _locked ? 'Unlock' : 'Lock',
            onPressed: _toggleLock,
          ),
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'project') _selectProject();
              if (v == 'trackers') _manageTrackers();
              if (v == 'delete') _delete();
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'project', child: Text('Assign Project')),
              const PopupMenuItem(value: 'trackers', child: Text('Manage Trackers')),
              const PopupMenuItem(value: 'delete', child: Text('Delete Note')),
            ],
          ),
          IconButton(icon: const Icon(Icons.save), tooltip: 'Save', onPressed: _save),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (_selectedProject != null)
                  Container(
                    width: double.infinity,
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    padding: const EdgeInsets.all(8),
                    child: Text('Project: ${_selectedProject!.title}'),
                  ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _titleCtl,
                    decoration: const InputDecoration(labelText: 'Title'),
                    enabled: !_locked,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: TextField(
                    controller: _subtitleCtl,
                    decoration: const InputDecoration(labelText: 'Subtitle'),
                    enabled: !_locked,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: TextField(
                    controller: _tagsCtl,
                    decoration: const InputDecoration(labelText: 'Tags'),
                    enabled: !_locked,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _contentCtl,
                      decoration: const InputDecoration(
                        labelText: 'Content',
                        border: OutlineInputBorder(),
                      ),
                      enabled: !_locked,
                      maxLines: null,
                      expands: true,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Created: ${DateFormat.yMMMd().add_jm().format(_note.createdAt)}\n'
                    'Updated: ${DateFormat.yMMMd().add_jm().format(_note.lastUpdated)}',
                    style: const TextStyle(fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
    );
  }
}
