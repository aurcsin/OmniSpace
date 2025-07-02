// File: lib/pages/journal_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/omni_note.dart';
import '../models/project.dart';
import '../services/omni_note_service.dart';
import '../services/project_service.dart';
import '../services/collection_service.dart';  // new service for note collections
import '../models/collection.dart';            // new model
import '../widgets/main_menu_drawer.dart';

enum DateRangeFilter { all, day, week, month, year }

class JournalPage extends StatefulWidget {
  const JournalPage({Key? key}) : super(key: key);
  @override
  State<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  bool _selectionMode = false;
  final Set<String> _selectedIds = {};
  String _searchQuery = '';
  DateRangeFilter _dateFilter = DateRangeFilter.all;

  List<OmniNote> get _notes => OmniNoteService.instance.notes;

  List<OmniNote> get _filteredNotes {
    final now = DateTime.now();
    DateTime start;
    switch (_dateFilter) {
      case DateRangeFilter.day:
        start = DateTime(now.year, now.month, now.day);
        break;
      case DateRangeFilter.week:
        start = now.subtract(Duration(days: now.weekday - 1));
        break;
      case DateRangeFilter.month:
        start = DateTime(now.year, now.month, 1);
        break;
      case DateRangeFilter.year:
        start = DateTime(now.year, 1, 1);
        break;
      case DateRangeFilter.all:
      default:
        start = DateTime.fromMillisecondsSinceEpoch(0);
    }
    DateTime end;
    switch (_dateFilter) {
      case DateRangeFilter.day:
        end = start.add(const Duration(days: 1));
        break;
      case DateRangeFilter.week:
        end = start.add(const Duration(days: 7));
        break;
      case DateRangeFilter.month:
        end = DateTime(start.year, start.month + 1, 1);
        break;
      case DateRangeFilter.year:
        end = DateTime(start.year + 1, 1, 1);
        break;
      case DateRangeFilter.all:
      default:
        end = DateTime.now().add(const Duration(days: 36500));
    }
    final q = _searchQuery.toLowerCase();
    return _notes.where((n) {
      final inDate = _dateFilter == DateRangeFilter.all ||
          (n.createdAt.isAfter(start) && n.createdAt.isBefore(end));
      final inSearch = q.isEmpty ||
          n.title.toLowerCase().contains(q) ||
          n.content.toLowerCase().contains(q);
      return inDate && inSearch;
    }).toList();
  }

  void _toggleSelect(String id) {
    setState(() {
      if (!_selectedIds.remove(id)) _selectedIds.add(id);
      if (_selectedIds.isEmpty) _selectionMode = false;
    });
  }

  void _enterSelection(String id) {
    setState(() {
      _selectionMode = true;
      _selectedIds.add(id);
    });
  }

  void _exitSelection() {
    setState(() {
      _selectionMode = false;
      _selectedIds.clear();
    });
  }

  /// Assign selected notes to a Project
  Future<void> _batchAssignProject() async {
    final proj = await _pickProject();
    if (proj != null) {
      for (var id in _selectedIds) {
        final note = OmniNoteService.instance.getNoteById(id);
        if (note != null) {
          note.projectId = proj.id;
          await OmniNoteService.instance.saveNote(note);
        }
      }
    }
    _exitSelection();
  }

  /// Assign selected notes to a Collection
  Future<void> _batchAssignCollection() async {
    final coll = await _pickCollection();
    if (coll != null) {
      await CollectionService.instance.addNotes(coll.id, _selectedIds.toList());
    }
    _exitSelection();
  }

  /// Show list of projects (plus “New Project”), returns chosen or newly created
  Future<Project?> _pickProject() async {
    return await showDialog<Project?>(
      context: context,
      builder: (ctx) {
        final allProjects = ProjectService.instance.all;
        return AlertDialog(
          title: const Text('Assign to Project'),
          content: SizedBox(
            width: 300,
            height: 400,
            child: ListView(
              children: [
                ...allProjects.map((p) => ListTile(
                      title: Text(p.title),
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
    ).then((proj) async {
      if (proj == null) {
        // create new
        final nameCtl = TextEditingController();
        final ok = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('New Project'),
            content: TextField(controller: nameCtl, decoration: const InputDecoration(labelText: 'Name')),
            actions: [
              TextButton(onPressed: () => Navigator.pop(_, false), child: const Text('Cancel')),
              ElevatedButton(onPressed: () => Navigator.pop(_, true), child: const Text('Create')),
            ],
          ),
        );
        if (ok == true && nameCtl.text.trim().isNotEmpty) {
          final newProj = Project(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: nameCtl.text.trim(),
            noteIds: [],
          );
          await ProjectService.instance.save(newProj);
          return newProj;
        }
        return null;
      }
      return proj;
    });
  }

  /// Show list of collections (plus “New Collection”), returns chosen
  Future<NoteCollection?> _pickCollection() async {
    return await showDialog<NoteCollection?>(
      context: context,
      builder: (ctx) {
        final allCols = CollectionService.instance.all;
        return AlertDialog(
          title: const Text('Add to Collection'),
          content: SizedBox(
            width: 300,
            height: 400,
            child: ListView(
              children: [
                ...allCols.map((c) => ListTile(
                      title: Text(c.name),
                      onTap: () => Navigator.pop(ctx, c),
                    )),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.create_new_folder),
                  title: const Text('New Collection'),
                  onTap: () => Navigator.pop(ctx, null),
                ),
              ],
            ),
          ),
        );
      },
    ).then((col) async {
      if (col == null) {
        final nameCtl = TextEditingController();
        final ok = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('New Collection'),
            content: TextField(controller: nameCtl, decoration: const InputDecoration(labelText: 'Name')),
            actions: [
              TextButton(onPressed: () => Navigator.pop(_, false), child: const Text('Cancel')),
              ElevatedButton(onPressed: () => Navigator.pop(_, true), child: const Text('Create')),
            ],
          ),
        );
        if (ok == true && nameCtl.text.trim().isNotEmpty) {
          final newCol = NoteCollection(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: nameCtl.text.trim(),
            noteIds: [],
          );
          await CollectionService.instance.create(newCol);
          return newCol;
        }
        return null;
      }
      return col;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MainMenuDrawer(),
      appBar: AppBar(
        title: _selectionMode
            ? Text('${_selectedIds.length} selected')
            : const Text('Journal'),
        leading: _selectionMode
            ? IconButton(icon: const Icon(Icons.close), onPressed: _exitSelection)
            : IconButton(
                icon: const Icon(Icons.help_outline),
                tooltip: 'Help',
                onPressed: () => _showHelp(context),
              ),
        actions: [
          if (_selectionMode) ...[
            IconButton(
              icon: const Icon(Icons.folder_special),
              tooltip: 'Add to Project',
              onPressed: _batchAssignProject,
            ),
            IconButton(
              icon: const Icon(Icons.collections_bookmark),
              tooltip: 'Add to Collection',
              onPressed: _batchAssignCollection,
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search notes…'),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),

          // Date-range toggles
          ToggleButtons(
            isSelected: DateRangeFilter.values.map((f) => f == _dateFilter).toList(),
            onPressed: (i) => setState(() => _dateFilter = DateRangeFilter.values[i]),
            children: const [
              Padding(padding: EdgeInsets.all(8), child: Text('All')),
              Padding(padding: EdgeInsets.all(8), child: Text('Day')),
              Padding(padding: EdgeInsets.all(8), child: Text('Week')),
              Padding(padding: EdgeInsets.all(8), child: Text('Month')),
              Padding(padding: EdgeInsets.all(8), child: Text('Year')),
            ],
          ),
          const Divider(),

          // Notes list
          Expanded(
            child: _filteredNotes.isEmpty
                ? const Center(child: Text('No matching notes.'))
                : ListView.builder(
                    itemCount: _filteredNotes.length,
                    itemBuilder: (_, i) {
                      final note = _filteredNotes[i];
                      final selected = _selectedIds.contains(note.id);
                      final proj = note.projectId != null
                          ? ProjectService.instance.getById(note.projectId!)
                          : null;
                      return ListTile(
                        leading: _selectionMode
                            ? Checkbox(value: selected, onChanged: (_) => _toggleSelect(note.id))
                            : null,
                        title: Row(
                          children: [
                            if (note.isStarred)
                              const Icon(Icons.star, color: Colors.amber, size: 18),
                            const SizedBox(width: 4),
                            Text(
                              note.title.isEmpty ? '(No Title)' : note.title,
                              style: note.isStarred
                                  ? const TextStyle(fontWeight: FontWeight.bold)
                                  : null,
                            ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(note.content, maxLines: 1, overflow: TextOverflow.ellipsis),
                            if (proj != null)
                              Text('Project: ${proj.title}',
                                  style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
                            Text(DateFormat.yMMMd().add_jm().format(note.lastUpdated),
                                style: const TextStyle(fontSize: 10)),
                          ],
                        ),
                        onLongPress: () => _enterSelection(note.id),
                        onTap: _selectionMode
                            ? () => _toggleSelect(note.id)
                            : () => Navigator.of(context)
                                .push(MaterialPageRoute(builder: (_) => NoteDetailPage(omniNote: note)))
                                .then((_) => setState(() {})),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: _selectionMode
          ? null
          : FloatingActionButton(
              onPressed: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => const NoteDetailPage()))
                  .then((_) => setState(() {})),
              child: const Icon(Icons.add),
            ),
    );
  }

  void _showHelp(BuildContext ctx) {
    showDialog<void>(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('Journal Help'),
        content: const Text(
          '• This page shows your journal entries (notes).\n'
          '• Long-press an entry to select multiple notes for batch operations.\n'
          '• Use the search bar or date toggles to filter entries.\n'
          '• Tap the ✚ FAB to create a new note. In the editor you can assign a project,\n'
          '  link an elemental spirit (for realm affinity), set a mood, and star your favorites.\n'
          '• Starred entries appear with a ★ icon.\n'
          '• You can group notes into Collections via the folder icon.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Got it!'))
        ],
      ),
    );
  }
}
