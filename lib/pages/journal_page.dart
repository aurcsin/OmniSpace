// lib/pages/journal_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:omnispace/models/omni_note.dart';
import 'package:omnispace/models/project.dart';
import 'package:omnispace/models/note_collection.dart';
import 'package:omnispace/services/omni_note_service.dart';
import 'package:omnispace/services/project_service.dart';
import 'package:omnispace/services/note_collection_service.dart';
import 'package:omnispace/widgets/main_menu_drawer.dart';
import 'package:omnispace/widgets/help_button.dart';
import 'package:omnispace/pages/note_detail_page.dart';

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

  final _noteSvc = OmniNoteService.instance;
  final _projSvc = ProjectService.instance;
  final _collSvc = NoteCollectionService.instance;

  List<NoteCollection> _collections = [];
  String? _activeCollectionId;

  @override
  void initState() {
    super.initState();
    _collections = _collSvc.all;
  }

  List<OmniNote> get _notes => _noteSvc.notes;

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
    final base = _notes.where((n) {
      final inDate = _dateFilter == DateRangeFilter.all ||
          (n.createdAt.isAfter(start) && n.createdAt.isBefore(end));
      final inSearch = q.isEmpty ||
          n.title.toLowerCase().contains(q) ||
          n.content.toLowerCase().contains(q);
      return inDate && inSearch;
    }).toList();

    if (_activeCollectionId != null) {
      final col =
          _collections.firstWhere((c) => c.id == _activeCollectionId);
      return base.where((n) => col.noteIds.contains(n.id)).toList();
    }
    return base;
  }

  void _toggleSelection(String id) {
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

  Future<void> _batchAssignProject() async {
    final picked = await showDialog<Project?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add to Project'),
        content: SizedBox(
          width: 300,
          height: 400,
          child: ListView(
            children: [
              ..._projSvc.all.map((p) => ListTile(
                    title: Text(p.title),
                    selected: _selectedIds.any((id) {
                      final note = _noteSvc.getById(id);
                      return note?.projectId == p.id;
                    }),
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
      ),
    );

    if (picked == null) {
      final nameCtl = TextEditingController();
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx2) => AlertDialog(
          title: const Text('New Project'),
          content: TextField(
            controller: nameCtl,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx2, false),
                child: const Text('Cancel')),
            ElevatedButton(
                onPressed: () => Navigator.pop(ctx2, true),
                child: const Text('Create')),
          ],
        ),
      );
      if (ok != true || nameCtl.text.trim().isEmpty) return;

      final toAssign = Project(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: nameCtl.text.trim(),
        noteIds: [],
      );
      await _projSvc.save(toAssign);
      for (final id in _selectedIds) {
        final note = _noteSvc.getById(id);
        if (note != null) {
          note.projectId = toAssign.id;
          await _noteSvc.saveNote(note);
        }
      }
    } else {
      for (final id in _selectedIds) {
        final note = _noteSvc.getById(id);
        if (note != null) {
          note.projectId = picked.id;
          await _noteSvc.saveNote(note);
        }
      }
    }

    _exitSelection();
  }

  Future<void> _batchCreateCollection() async {
    final nameCtl = TextEditingController();
    final colName = await showDialog<String?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Note Collection'),
        content: TextField(
          controller: nameCtl,
          decoration:
              const InputDecoration(labelText: 'Collection Name'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () =>
                  Navigator.pop(ctx, nameCtl.text.trim()),
              child: const Text('Create')),
        ],
      ),
    );
    if (colName == null || colName.isEmpty) return;

    final id = DateTime.now().millisecondsSinceEpoch.toString();
    await _collSvc.create(
        id: id, name: colName, noteIds: _selectedIds.toList());
    setState(() => _collections = _collSvc.all);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Created collection "$colName"')),
    );
    _exitSelection();
  }

  Future<void> _toggleStar(OmniNote note) async {
    note.isStarred = !note.isStarred;
    await _noteSvc.saveNote(note);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MainMenuDrawer(),
      appBar: AppBar(
        leading: _selectionMode
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: _exitSelection,
              )
            : IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
        title: _selectionMode
            ? Text('${_selectedIds.length} selected')
            : const Text('Journal'),
        actions: [
          if (_selectionMode) ...[
            IconButton(
              icon: const Icon(Icons.folder_special),
              tooltip: 'Add to Project',
              onPressed: _batchAssignProject,
            ),
            IconButton(
              icon: const Icon(Icons.collections_bookmark),
              tooltip: 'New Collection',
              onPressed: _batchCreateCollection,
            ),
          ] else ...[
            HelpButton(
              helpTitle: 'Journal Help',
              helpText: '''
• Journal: reflect & track your insights.  
• Tap the star to favorite an entry.  
• Favorites are highlighted.  
• Select entries to batch-assign projects or create collections.  
• Tap “+” to compose a new entry.''',
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search notes…',
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: ToggleButtons(
              isSelected: DateRangeFilter.values
                  .map((f) => f == _dateFilter)
                  .toList(),
              onPressed: (i) => setState(
                  () => _dateFilter = DateRangeFilter.values[i]),
              children: const [
                Padding(
                    padding: EdgeInsets.all(8), child: Text('All')),
                Padding(
                    padding: EdgeInsets.all(8), child: Text('Day')),
                Padding(
                    padding: EdgeInsets.all(8), child: Text('Week')),
                Padding(
                    padding: EdgeInsets.all(8), child: Text('Month')),
                Padding(
                    padding: EdgeInsets.all(8), child: Text('Year')),
              ],
            ),
          ),
          if (_collections.isNotEmpty) ...[
            const Divider(height: 1),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                  vertical: 8, horizontal: 12),
              child: Row(
                children: _collections.map((col) {
                  final active = col.id == _activeCollectionId;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(col.name),
                      selected: active,
                      onSelected: (_) => setState(() =>
                          _activeCollectionId =
                              active ? null : col.id),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
          const Divider(),
          Expanded(
            child: _filteredNotes.isEmpty
                ? const Center(
                    child: Text('No matching notes.'),
                  )
                : ListView.builder(
                    itemCount: _filteredNotes.length,
                    itemBuilder: (_, i) {
                      final n = _filteredNotes[i];
                      final selected =
                          _selectedIds.contains(n.id);
                      final proj = n.projectId == null
                          ? null
                          : _projSvc.getById(n.projectId!);
                      return ListTile(
                        leading: _selectionMode
                            ? Checkbox(
                                value: selected,
                                onChanged: (_) =>
                                    _toggleSelection(n.id),
                              )
                            : IconButton(
                                icon: Icon(
                                  n.isStarred
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: n.isStarred
                                      ? Colors.amber
                                      : null,
                                ),
                                onPressed: () =>
                                    _toggleStar(n),
                              ),
                        tileColor: n.isStarred
                            ? Theme.of(context)
                                .colorScheme
                                .secondary
                                .withOpacity(0.1)
                            : null,
                        title: Text(
                            n.title.isEmpty ? '(No Title)' : n.title),
                        subtitle: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              n.content,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (proj != null)
                              Text(
                                'Project: ${proj.title}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            Text(
                              DateFormat.yMMMd()
                                  .add_jm()
                                  .format(n.lastUpdated),
                              style: const TextStyle(
                                  fontSize: 10),
                            ),
                          ],
                        ),
                        onLongPress: () => _enterSelection(n.id),
                        onTap: _selectionMode
                            ? () => _toggleSelection(n.id)
                            : () => Navigator.of(context)
                                .push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        NoteDetailPage(
                                      omniNote: n,
                                    ),
                                  ),
                                )
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
                  .push(
                    MaterialPageRoute(
                      builder: (_) =>
                          const NoteDetailPage(),
                    ),
                  )
                  .then((_) => setState(() {})),
              child: const Icon(Icons.add),
            ),
    );
  }
}
