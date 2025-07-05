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
  final _noteSvc = OmniNoteService.instance;
  final _projSvc = ProjectService.instance;
  final _collSvc = NoteCollectionService.instance;

  bool _loading = true;
  bool _selectionMode = false;
  final _selectedIds = <String>{};
  String _searchQuery = '';
  DateRangeFilter _dateFilter = DateRangeFilter.all;

  List<NoteCollection> _collections = [];
  String? _activeCollectionId;

  @override
  void initState() {
    super.initState();
    _initServices();
  }

  Future<void> _initServices() async {
    await _noteSvc.init();
    await _collSvc.init();
    setState(() {
      _collections = _collSvc.all;
      _loading = false;
    });
  }

  Future<void> _reloadNotes() async {
    await _noteSvc.init();
    setState(() {});
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
    final end = {
      DateRangeFilter.day:    () => start.add(const Duration(days: 1)),
      DateRangeFilter.week:   () => start.add(const Duration(days: 7)),
      DateRangeFilter.month:  () => DateTime(start.year, start.month + 1, 1),
      DateRangeFilter.year:   () => DateTime(start.year + 1, 1, 1),
      DateRangeFilter.all:    () => DateTime.now().add(const Duration(days: 36500)),
    }[_dateFilter]!();

    final q = _searchQuery.toLowerCase();
    var base = _notes.where((n) {
      final inDate = _dateFilter == DateRangeFilter.all
          ? true
          : n.createdAt.isAfter(start) && n.createdAt.isBefore(end);
      final inSearch = q.isEmpty ||
          n.title.toLowerCase().contains(q) ||
          n.content.toLowerCase().contains(q);
      return inDate && inSearch;
    }).toList();

    if (_activeCollectionId != null) {
      final col = _collections.firstWhere((c) => c.id == _activeCollectionId);
      base = base.where((n) => col.noteIds.contains(n.id)).toList();
    }
    return base;
  }

  void _enterSelection(String id) {
    setState(() {
      _selectionMode = true;
      _selectedIds.add(id);
    });
  }

  void _toggleSelection(String id) {
    setState(() {
      if (!_selectedIds.remove(id)) _selectedIds.add(id);
      if (_selectedIds.isEmpty) _selectionMode = false;
    });
  }

  Future<void> _toggleStar(OmniNote note) async {
    note.isStarred = !note.isStarred;
    await _noteSvc.save(note);
    setState(() {});
  }

  Future<void> _showCreateCollection() async {
    final ctl = TextEditingController();
    final name = await showDialog<String?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Collection'),
        content: TextField(
          controller: ctl,
          decoration: const InputDecoration(labelText: 'Collection Name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, ctl.text.trim()), child: const Text('Create')),
        ],
      ),
    );
    if (name?.isNotEmpty == true) {
      await _collSvc.create(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name!,
        noteIds: [],
      );
      await _collSvc.init();
      setState(() => _collections = _collSvc.all);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Created collection "$name"')),
      );
    }
  }

  Future<void> _showNewMenu() async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
            leading: const Icon(Icons.note_add),
            title: const Text('New Note'),
            onTap: () async {
              Navigator.pop(context);
              final saved = await Navigator.of(context).push<bool>(
                MaterialPageRoute(builder: (_) => const NoteDetailPage()),
              );
              if (saved == true) await _reloadNotes();
            },
          ),
          ListTile(
            leading: const Icon(Icons.create_new_folder),
            title: const Text('New Collection'),
            onTap: () {
              Navigator.pop(context);
              _showCreateCollection();
            },
          ),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      drawer: const MainMenuDrawer(),
      appBar: AppBar(
        title: _selectionMode
            ? Text('${_selectedIds.length} selected')
            : const Text('Journal'),
        actions: [
          if (_selectionMode)
            IconButton(icon: const Icon(Icons.close), onPressed: () {
              setState(() {
                _selectionMode = false;
                _selectedIds.clear();
              });
            })
          else
            HelpButton(
              helpTitle: 'Journal Help',
              helpText: '''
• Tap “+” to create a note or collection  
• Long-press entries to select  
• Search and filter by date or collection  
• Star to favorite.''',
            ),
        ],
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Search notes…',
            ),
            onChanged: (v) => setState(() => _searchQuery = v),
          ),
        ),
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
        if (_collections.isNotEmpty) ...[
          const Divider(),
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: _collections.map((col) {
                final active = col.id == _activeCollectionId;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(col.name),
                    selected: active,
                    onSelected: (_) => setState(() => _activeCollectionId = active ? null : col.id),
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(),
        ],
        Expanded(
          child: _filteredNotes.isEmpty
              ? const Center(child: Text('No matching notes.'))
              : ListView.builder(
                  itemCount: _filteredNotes.length,
                  itemBuilder: (_, i) {
                    final n = _filteredNotes[i];
                    final proj = n.projectId == null ? null : _projSvc.getById(n.projectId!);
                    return ListTile(
                      leading: _selectionMode
                          ? Checkbox(
                              value: _selectedIds.contains(n.id),
                              onChanged: (_) => _toggleSelection(n.id),
                            )
                          : IconButton(
                              icon: Icon(n.isStarred ? Icons.star : Icons.star_border),
                              color: n.isStarred ? Colors.amber : null,
                              onPressed: () => _toggleStar(n),
                            ),
                      title: Text(n.title.isEmpty ? '(No Title)' : n.title),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(n.content, maxLines: 1, overflow: TextOverflow.ellipsis),
                          if (proj != null)
                            Text('Project: ${proj.title}', style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
                          Text(DateFormat.yMMMd().add_jm().format(n.lastUpdated), style: const TextStyle(fontSize: 10)),
                        ],
                      ),
                      tileColor: n.isStarred
                          ? Theme.of(context).colorScheme.secondary.withOpacity(0.1)
                          : null,
                      onLongPress: () => _enterSelection(n.id),
                      onTap: _selectionMode
                          ? () => _toggleSelection(n.id)
                          : () async {
                              final saved = await Navigator.of(context).push<bool>(
                                MaterialPageRoute(builder: (_) => NoteDetailPage(omniNote: n)),
                              );
                              if (saved == true) await _reloadNotes();
                            },
                    );
                  },
                ),
        ),
      ]),
      floatingActionButton: _selectionMode
          ? null
          : FloatingActionButton(onPressed: _showNewMenu, child: const Icon(Icons.add)),
    );
  }
}
