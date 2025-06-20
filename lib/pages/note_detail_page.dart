import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  late TextEditingController _titleCtl, _subtitleCtl, _tagsCtl, _contentCtl;
  bool _loading = false;
  bool _locked = false;
  bool _starred = false;
  Project? _selectedProject;

  @override
  void initState() {
    super.initState();
    _note = widget.omniNote ??
        OmniNote(
          id: generateId(),
          title: '',
          subtitle: '',
          content: '',
          tags: '',
        );
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
    Navigator.pop(context, _note);
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
        final all = ProjectService.instance.all;
        return AlertDialog(
          title: const Text('Assign Project'),
          content: SizedBox(
            width: 300,
            height: 400,
            child: ListView(
              children: [
                ...all.map((p) => RadioListTile<String>(
                      value: p.id,
                      groupValue: _selectedProject?.id,
                      title: Text(p.title),
                      onChanged: (_) => Navigator.pop(ctx, p),
                    )),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.add),
                  title: const Text('New Project'),
                  onTap: () {
                    Navigator.pop(ctx, null);
                    // fallback into save routine below
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
    } else {
      // create new project on the fly
      final nameCtl = TextEditingController();
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx2) => AlertDialog(
          title: const Text('New Project'),
          content: TextField(
            controller: nameCtl,
            decoration: const InputDecoration(labelText: 'Project Name'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx2, false), child: const Text('Cancel')),
            ElevatedButton(onPressed: () => Navigator.pop(ctx2, true), child: const Text('Create')),
          ],
        ),
      );
      if (ok == true && nameCtl.text.trim().isNotEmpty) {
        final newProj = Project(id: generateId(), title: nameCtl.text.trim());
        await ProjectService.instance.save(newProj);
        setState(() => _selectedProject = newProj);
      }
    }
  }

  void _findInNote() {
    showDialog(
      context: context,
      builder: (ctx) {
        var query = '';
        return AlertDialog(
          title: const Text('Find in Note'),
          content: TextField(
            onChanged: (v) => query = v,
            decoration: const InputDecoration(hintText: 'Search…'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                // TODO: highlight matches
                Navigator.pop(ctx);
              },
              child: const Text('Find'),
            ),
          ],
        );
      },
    );
  }

  void _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Note?'),
        content: const Text('This will be gone forever!'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(_, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(_, true), child: const Text('Delete')),
        ],
      ),
    );
    if (ok == true) {
      await OmniNoteService.instance.deleteNote(_note.id);
      Navigator.pop(context);
    }
  }

  void _manageTrackers() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => OmniTrackerSelector(ownerId: _note.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      drawer: const MainMenuDrawer(),
      appBar: AppBar(
        title: Text(widget.omniNote == null ? 'New Note' : 'Edit Note'),
        actions: [
          IconButton(icon: Icon(_starred ? Icons.star : Icons.star_border), onPressed: _toggleStar),
          IconButton(icon: Icon(_locked ? Icons.lock : Icons.lock_open), onPressed: _toggleLock),
          IconButton(icon: const Icon(Icons.find_in_page), onPressed: _findInNote),
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'project') _selectProject();
              if (v == 'trackers') _manageTrackers();
              if (v == 'delete') _delete();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'project', child: Text('Assign Project')),
              PopupMenuItem(value: 'trackers', child: Text('Manage Trackers')),
              PopupMenuItem(value: 'delete', child: Text('Delete Note')),
            ],
          ),
          IconButton(icon: const Icon(Icons.save), onPressed: _save),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (_selectedProject != null)
                  Container(
                    width: double.infinity,
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    padding: const EdgeInsets.all(8),
                    child: Text('Project: ${_selectedProject!.title}'),
                  ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: ListView(
                      children: [
                        TextField(
                          controller: _titleCtl,
                          decoration: const InputDecoration(labelText: 'Title'),
                          enabled: !_locked,
                        ),
                        TextField(
                          controller: _subtitleCtl,
                          decoration: const InputDecoration(labelText: 'Subtitle'),
                          enabled: !_locked,
                        ),
                        TextField(
                          controller: _tagsCtl,
                          decoration: const InputDecoration(labelText: 'Tags'),
                          enabled: !_locked,
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _contentCtl,
                          decoration: const InputDecoration(
                            labelText: 'Content',
                            border: OutlineInputBorder(),
                          ),
                          enabled: !_locked,
                          maxLines: null,
                          minLines: 6,
                        ),
                      ],
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
