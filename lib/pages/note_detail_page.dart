// File: lib/pages/note_detail_page.dart

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;

import '../models/omni_note.dart';
import '../models/project.dart';
import '../services/omni_note_service.dart';
import '../services/project_service.dart';
import '../widgets/main_menu_drawer.dart';
import '../widgets/omni_tracker_selector.dart';
import '../utils/id_generator.dart';

class NoteDetailPage extends StatefulWidget {
  final OmniNote? omniNote;
  const NoteDetailPage({Key? key, this.omniNote}) : super(key: key);

  @override
  _NoteDetailPageState createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends State<NoteDetailPage> {
  late OmniNote _note;
  late TextEditingController _titleCtl;
  late TextEditingController _subtitleCtl;
  late TextEditingController _tagsCtl;
  late QuillController _quillCtl;
  Project? _selectedProject;
  bool _loading = false;

  @override
  void initState() {
    super.initState();

    // Initialize or create note
    _note = widget.omniNote ??
        OmniNote(
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

    // Prepare rich-text controller
    Delta delta;
    if (_note.content.trim().isEmpty) {
      delta = Delta()..insert('\n');
    } else {
      try {
        final List<dynamic> json = jsonDecode(_note.content);
        delta = Delta.fromJson(json);
      } catch (_) {
        delta = Delta()..insert(_note.content + '\n');
      }
    }
    _quillCtl = QuillController(
      document: Document.fromDelta(delta),
      selection: const TextSelection.collapsed(offset: 0),
    );

    // Load project if assigned
    if (_note.projectId != null) {
      _selectedProject =
          ProjectService.instance.getById(_note.projectId!);
    }
  }

  @override
  void dispose() {
    _titleCtl.dispose();
    _subtitleCtl.dispose();
    _tagsCtl.dispose();
    _quillCtl.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    setState(() => _loading = true);

    final contentJson =
        jsonEncode(_quillCtl.document.toDelta().toJson());

    _note
      ..title = _titleCtl.text.trim()
      ..subtitle = _subtitleCtl.text
      ..tags = _tagsCtl.text
      ..content = contentJson
      ..lastUpdated = DateTime.now()
      ..projectId = _selectedProject?.id;

    await OmniNoteService.instance.saveNote(_note);

    setState(() => _loading = false);
    Navigator.pop(context);
  }

  Future<void> _selectProject() async {
    final proj = await showDialog<Project?>(
      context: context,
      builder: (ctx) {
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
                      onTap: () => Navigator.pop(ctx, p),
                    )),
                ListTile(
                  leading: const Icon(Icons.add),
                  title: const Text('New Project'),
                  onTap: () async {
                    final ctrl = TextEditingController();
                    final ok = await showDialog<bool>(
                      context: ctx,
                      builder: (ctx2) => AlertDialog(
                        title: const Text('New Project'),
                        content: TextField(
                          controller: ctrl,
                          decoration:
                              const InputDecoration(labelText: 'Name'),
                        ),
                        actions: [
                          TextButton(
                              onPressed: () =>
                                  Navigator.pop(ctx2, false),
                              child: const Text('Cancel')),
                          ElevatedButton(
                              onPressed: () =>
                                  Navigator.pop(ctx2, true),
                              child: const Text('Create')),
                        ],
                      ),
                    );
                    if (ok == true &&
                        ctrl.text.trim().isNotEmpty) {
                      final p = Project(
                        id: generateId(),
                        title: ctrl.text.trim(),
                        noteIds: [],
                      );
                      await ProjectService.instance.save(p);
                      Navigator.pop(ctx, p);
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
    if (proj != null) {
      setState(() => _selectedProject = proj);
    }
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
        title:
            Text(widget.omniNote == null ? 'New Note' : 'Edit Note'),
        actions: [
          IconButton(
            icon: const Icon(Icons.folder_open),
            tooltip: 'Assign Project',
            onPressed: _selectProject,
          ),
          IconButton(
            icon: const Icon(Icons.track_changes),
            tooltip: 'Manage Trackers',
            onPressed: _manageTrackers,
          ),
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Save',
            onPressed: _saveNote,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (_selectedProject != null)
                  Container(
                    width: double.infinity,
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withOpacity(0.1),
                    padding: const EdgeInsets.all(8),
                    child:
                        Text('Project: ${_selectedProject!.title}'),
                  ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: _titleCtl,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      hintText: 'Untitled',
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8.0),
                  child: TextFormField(
                    controller: _subtitleCtl,
                    decoration: const InputDecoration(
                        labelText: 'Subtitle'),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8.0),
                  child: TextFormField(
                    controller: _tagsCtl,
                    decoration: const InputDecoration(
                        labelText: 'Tags'),
                  ),
                ),
                QuillToolbar.basic(controller: _quillCtl),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: QuillEditor(
                      controller: _quillCtl,
                      scrollController: ScrollController(),
                      scrollable: true,
                      focusNode: FocusNode(),
                      autoFocus: false,
                      readOnly: false,
                      expands: false,
                      padding: EdgeInsets.zero,
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
