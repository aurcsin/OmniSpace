// File: lib/pages/project_forge_page.dart

import 'package:flutter/material.dart';

import '../models/project.dart';
import '../models/omni_note.dart';
import '../models/tracker.dart';
import '../models/tracker_type.dart';
import '../services/project_service.dart';
import '../services/omni_note_service.dart';
import '../services/tracker_service.dart';
import '../utils/id_generator.dart';
import '../widgets/main_menu_drawer.dart';
import 'note_detail_page.dart';
import 'tracker_forge_page.dart';

/// Allows creating or editing a Project, by picking notes & trackers.
class ProjectForgePage extends StatefulWidget {
  final Project? project;
  final List<String>? preselectedNotes;
  final List<String>? preselectedTrackers;

  const ProjectForgePage({
    Key? key,
    this.project,
    this.preselectedNotes,
    this.preselectedTrackers,
  }) : super(key: key);

  @override
  State<ProjectForgePage> createState() => _ProjectForgePageState();
}

enum ForgeSort { chronoDesc, chronoAsc, alphaAsc, alphaDesc }

class _ProjectForgePageState extends State<ProjectForgePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleCtl;

  // selections
  late Set<String> _noteIds;
  late Set<String> _trackerIds;

  // filters & sorts
  String _noteQuery = '';
  String _trackerQuery = '';
  ForgeSort _noteSort = ForgeSort.chronoDesc;
  ForgeSort _trackerSort = ForgeSort.chronoDesc;

  @override
  void initState() {
    super.initState();
    final p = widget.project;
    _titleCtl = TextEditingController(text: p?.title ?? '');
    _noteIds = {
      ...(p?.noteIds ?? []),
      ...?widget.preselectedNotes,
    };
    _trackerIds = {
      ...(p?.trackerIds ?? []),
      ...?widget.preselectedTrackers,
    };
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
      ..title = _titleCtl.text.trim()
      ..noteIds = _noteIds.toList()
      ..trackerIds = _trackerIds.toList();
    await ProjectService.instance.save(project);
    Navigator.of(context).pop(project);
  }

  List<OmniNote> get _filteredNotes {
    final all = OmniNoteService.instance.notes;
    final q = _noteQuery.toLowerCase();
    var list = all.where((n) {
      return n.title.toLowerCase().contains(q) ||
          n.subtitle.toLowerCase().contains(q) ||
          n.content.toLowerCase().contains(q);
    }).toList();
    switch (_noteSort) {
      case ForgeSort.chronoDesc:
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case ForgeSort.chronoAsc:
        list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case ForgeSort.alphaAsc:
        list.sort((a, b) => a.title.compareTo(b.title));
        break;
      case ForgeSort.alphaDesc:
        list.sort((a, b) => b.title.compareTo(a.title));
        break;
    }
    return list;
  }

  List<Tracker> get _filteredTrackers {
    final all = TrackerService.instance.all;
    final q = _trackerQuery.toLowerCase();
    var list = all.where((t) => t.title.toLowerCase().contains(q)).toList();

    // use numeric value of ID as a stand-in for creation time
    int idValue(String id) => int.tryParse(id) ?? 0;

    switch (_trackerSort) {
      case ForgeSort.chronoDesc:
        list.sort((a, b) => idValue(b.id).compareTo(idValue(a.id)));
        break;
      case ForgeSort.chronoAsc:
        list.sort((a, b) => idValue(a.id).compareTo(idValue(b.id)));
        break;
      case ForgeSort.alphaAsc:
        list.sort((a, b) => a.title.compareTo(b.title));
        break;
      case ForgeSort.alphaDesc:
        list.sort((a, b) => b.title.compareTo(a.title));
        break;
    }
    return list;
  }

  IconData _iconFor(TrackerType type) {
    switch (type) {
      case TrackerType.goal:
        return Icons.flag;
      case TrackerType.event:
        return Icons.event;
      case TrackerType.routine:
        return Icons.repeat;
      case TrackerType.series:
        return Icons.collections;
    }
  }

  void _createNewTracker() {
    showModalBottomSheet<TrackerType>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: TrackerType.values.map((type) {
            return ListTile(
              leading: Icon(_iconFor(type)),
              title: Text('${type.name[0].toUpperCase()}${type.name.substring(1)}'),
              onTap: () => Navigator.pop(context, type),
            );
          }).toList(),
        ),
      ),
    ).then((type) {
      if (type != null) {
        Navigator.of(context)
            .push<Tracker>(MaterialPageRoute(builder: (_) => TrackerForgePage(type: type)))
            .then((t) {
          if (t != null) {
            setState(() => _trackerIds.add(t.id));
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MainMenuDrawer(),
      appBar: AppBar(
        title: Text(widget.project == null ? 'New Project' : 'Edit Project'),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _save),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              TextFormField(
                controller: _titleCtl,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 24),

              // Notes section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Notes', style: Theme.of(context).textTheme.titleMedium),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => Navigator.of(context)
                        .push(MaterialPageRoute(builder: (_) => const NoteDetailPage()))
                        .then((_) => setState(() {})),
                  ),
                ],
              ),
              // filter & sort notes
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: 'Filter notes…',
                      ),
                      onChanged: (v) => setState(() => _noteQuery = v),
                    ),
                  ),
                  PopupMenuButton<ForgeSort>(
                    icon: const Icon(Icons.sort),
                    onSelected: (s) => setState(() => _noteSort = s),
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: ForgeSort.chronoDesc, child: Text('Newest first')),
                      PopupMenuItem(value: ForgeSort.chronoAsc, child: Text('Oldest first')),
                      PopupMenuItem(value: ForgeSort.alphaAsc, child: Text('A → Z')),
                      PopupMenuItem(value: ForgeSort.alphaDesc, child: Text('Z → A')),
                    ],
                  ),
                ],
              ),
              ..._filteredNotes.map((n) {
                return CheckboxListTile(
                  value: _noteIds.contains(n.id),
                  title: Text(n.title.isNotEmpty ? n.title : '(No Title)'),
                  onChanged: (v) {
                    setState(() {
                      if (v == true) {
                        _noteIds.add(n.id);
                      } else {
                        _noteIds.remove(n.id);
                      }
                    });
                  },
                );
              }),

              const SizedBox(height: 32),

              // Trackers section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Trackers', style: Theme.of(context).textTheme.titleMedium),
                  IconButton(icon: const Icon(Icons.add), onPressed: _createNewTracker),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: 'Filter trackers…',
                      ),
                      onChanged: (v) => setState(() => _trackerQuery = v),
                    ),
                  ),
                  PopupMenuButton<ForgeSort>(
                    icon: const Icon(Icons.sort),
                    onSelected: (s) => setState(() => _trackerSort = s),
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: ForgeSort.chronoDesc, child: Text('Newest first')),
                      PopupMenuItem(value: ForgeSort.chronoAsc, child: Text('Oldest first')),
                      PopupMenuItem(value: ForgeSort.alphaAsc, child: Text('A → Z')),
                      PopupMenuItem(value: ForgeSort.alphaDesc, child: Text('Z → A')),
                    ],
                  ),
                ],
              ),
              ..._filteredTrackers.map((t) {
                return CheckboxListTile(
                  value: _trackerIds.contains(t.id),
                  title: Text(t.title),
                  subtitle: Text(t.type.name),
                  onChanged: (v) {
                    setState(() {
                      if (v == true) {
                        _trackerIds.add(t.id);
                      } else {
                        _trackerIds.remove(t.id);
                      }
                    });
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
