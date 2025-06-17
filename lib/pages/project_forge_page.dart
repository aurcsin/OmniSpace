import 'package:flutter/material.dart';
import '../models/project.dart';
import '../services/project_service.dart';
import '../services/omni_note_service.dart';
import '../services/tracker_service.dart';
import '../widgets/main_menu_drawer.dart';
import 'note_detail_page.dart' as detail;
import 'forge_editor_page.dart';
import '../utils/id_generator.dart';

class ProjectForgePage extends StatefulWidget {
  final Project? project;
  const ProjectForgePage({super.key, this.project});

  @override
  State<ProjectForgePage> createState() => _ProjectForgePageState();
}

class _ProjectForgePageState extends State<ProjectForgePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleCtl;
  late Set<String> _noteIds;
  late Set<String> _trackerIds;

  @override
  void initState() {
    super.initState();
    final p = widget.project;
    _titleCtl = TextEditingController(text: p?.title ?? '');
    _noteIds = {...(p?.noteIds ?? [])};
    _trackerIds = {...(p?.trackerIds ?? [])};
  }

  @override
  void dispose() {
    _titleCtl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final project = widget.project ?? Project(id: generateId());
    project
      ..title = _titleCtl.text
      ..noteIds = _noteIds.toList()
      ..trackerIds = _trackerIds.toList();
    await ProjectService.instance.save(project);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _createNote() async {
    await Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const detail.NoteDetailPage()));
    await OmniNoteService.instance.loadAllNotes();
    setState(() {});
  }

  Future<void> _createTracker() async {
    await Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const ForgeEditorPage()));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final notes = OmniNoteService.instance.notes;
    final trackers = TrackerService.instance.all;
    return Scaffold(
      drawer: const MainMenuDrawer(),
      appBar: AppBar(
        title: Text(widget.project == null ? 'New Project' : 'Edit Project'),
        actions: [IconButton(icon: const Icon(Icons.save), onPressed: _save)],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleCtl,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Notes',
                      style: Theme.of(context).textTheme.titleMedium),
                  IconButton(
                    icon: const Icon(Icons.add),
                    tooltip: 'New Note',
                    onPressed: _createNote,
                  ),
                ],
              ),
              ...notes.map((n) => CheckboxListTile(
                    value: _noteIds.contains(n.id),
                    title: Text(n.title.isNotEmpty ? n.title : '(No title)'),
                    onChanged: (val) {
                      setState(() {
                        if (val == true) {
                          _noteIds.add(n.id);
                        } else {
                          _noteIds.remove(n.id);
                        }
                      });
                    },
                  )),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Trackers',
                      style: Theme.of(context).textTheme.titleMedium),
                  IconButton(
                    icon: const Icon(Icons.add),
                    tooltip: 'New Tracker',
                    onPressed: _createTracker,
                  ),
                ],
              ),
              ...trackers.map((t) => CheckboxListTile(
                    value: _trackerIds.contains(t.id),
                    title: Text(t.title),
                    subtitle: Text(t.type.name),
                    onChanged: (val) {
                      setState(() {
                        if (val == true) {
                          _trackerIds.add(t.id);
                        } else {
                          _trackerIds.remove(t.id);
                        }
                      });
                    },
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
