// File: lib/pages/journal_page.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/omni_note.dart';
import '../models/project.dart';
import '../models/zone_theme.dart';
import '../models/spirit.dart';
import '../services/omni_note_service.dart';
import '../services/project_service.dart';
import '../services/spirit_service.dart';
import '../services/deck_service.dart';
import '../widgets/main_menu_drawer.dart';
import 'note_detail_page.dart';

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
  ZoneTheme? _realmFilter;

  final _noteSvc   = OmniNoteService.instance;
  final _projSvc   = ProjectService.instance;
  final _spiritSvc = SpiritService.instance;
  final _deckSvc   = DeckService.instance;

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
      DateRangeFilter.day:   start.add(const Duration(days: 1)),
      DateRangeFilter.week:  start.add(const Duration(days: 7)),
      DateRangeFilter.month: DateTime(start.year, start.month + 1, 1),
      DateRangeFilter.year:  DateTime(start.year + 1, 1, 1),
      DateRangeFilter.all:   DateTime.now().add(const Duration(days: 36500)),
    }[_dateFilter]!;

    final q = _searchQuery.toLowerCase();
    return _notes.where((n) {
      final inDate = _dateFilter == DateRangeFilter.all ||
          (n.createdAt.isAfter(start) && n.createdAt.isBefore(end));
      final inSearch = q.isEmpty ||
          n.title.toLowerCase().contains(q) ||
          n.content.toLowerCase().contains(q);
      final inRealm = _realmFilter == null || n.zone == _realmFilter;
      return inDate && inSearch && inRealm;
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

  Future<void> _batchAssignProject() async {
    final proj = await showDialog<Project?>(
      context: context,
      builder: (ctx) {
        final projects = _projSvc.all;
        return AlertDialog(
          title: const Text('Add to Project'),
          content: SizedBox(
            width: 300,
            height: 400,
            child: ListView(
              children: [
                ...projects.map((p) => ListTile(
                      title: Text(p.title),
                      onTap: () => Navigator.pop(ctx, p),
                    )),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.add),
                  title: const Text('New Project'),
                  onTap: () async {
                    final nameCtl = TextEditingController();
                    final ok = await showDialog<bool>(
                      context: ctx,
                      builder: (ctx2) => AlertDialog(
                        title: const Text('New Project'),
                        content: TextField(
                          controller: nameCtl,
                          decoration:
                              const InputDecoration(labelText: 'Name'),
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
                    if (ok == true && nameCtl.text.trim().isNotEmpty) {
                      final newProj = Project(
                        id: DateTime.now()
                            .millisecondsSinceEpoch
                            .toString(),
                        title: nameCtl.text.trim(),
                        noteIds: [],
                      );
                      await _projSvc.save(newProj);
                      Navigator.pop(ctx, newProj);
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
      for (var id in _selectedIds) {
        final note = _noteSvc.getNoteById(id);
        if (note != null) {
          note.projectId = proj.id;
          await _noteSvc.saveNote(note);
        }
      }
    }
    _exitSelection();
  }

  void _onRealmSelected(ZoneTheme? realm) {
    setState(() {
      _realmFilter = realm;
    });
  }

  Future<void> _drawRealmSpirit() async {
    if (_realmFilter == null) return;
    final s = await _deckSvc.drawFromRealm(_realmFilter!);
    final msg = s != null
        ? 'Drew ${s.name}!'
        : 'All ${_realmFilter!.displayName} spirits already in deck.';
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  Widget _buildRealmChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding:
          const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Row(
        children: [
          ChoiceChip(
            label: const Text('All'),
            selected: _realmFilter == null,
            onSelected: (_) => _onRealmSelected(null),
          ),
          const SizedBox(width: 8),
          ...ZoneTheme.values.map((realm) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                avatar: Icon(realm.icon,
                    size: 20, color: Colors.deepPurple),
                label: Text(realm.displayName),
                selected: _realmFilter == realm,
                onSelected: (_) => _onRealmSelected(realm),
                selectedColor: Colors.deepPurple.shade100,
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final masterSpirit = _realmFilter != null
        ? _spiritSvc.getPrimary(_realmFilter!)
        : null;
    final reps = _realmFilter != null
        ? _spiritSvc
            .forRealm(_realmFilter!)
            .where((s) => !s.isPrimary)
            .toList()
        : <Spirit>[];

    return Scaffold(
      drawer: const MainMenuDrawer(),
      appBar: AppBar(
        title: _selectionMode
            ? Text('${_selectedIds.length} selected')
            : const Text('Journal'),
        leading: _selectionMode
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: _exitSelection,
              )
            : null,
        actions: [
          if (_selectionMode)
            IconButton(
              icon: const Icon(Icons.folder_special),
              tooltip: 'Add to Project',
              onPressed: _batchAssignProject,
            ),
        ],
      ),
      body: Column(
        children: [
          _buildRealmChips(),
          if (masterSpirit != null) ...[
            Card(
              margin:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: ListTile(
                leading: Icon(masterSpirit.realm.icon,
                    size: 36, color: Colors.deepPurple),
                title: Text(masterSpirit.name,
                    style:
                        const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(masterSpirit.description),
              ),
            ),
            Wrap(
              spacing: 8,
              children: reps.map((s) {
                final inDeck =
                    _deckSvc.deck.spiritIds.contains(s.id);
                return ChoiceChip(
                  avatar: Icon(s.realm.icon,
                      size: 20,
                      color: inDeck ? Colors.grey : Colors.white),
                  label: Text(s.name),
                  selected: false,
                  onSelected: inDeck
                      ? null
                      : (_) async {
                          await _deckSvc.draw(s);
                          if (mounted) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(SnackBar(
                                    content:
                                        Text('Added ${s.name}')));
                          }
                        },
                  backgroundColor: inDeck
                      ? Colors.grey.shade300
                      : Colors.deepPurple,
                  labelStyle: TextStyle(
                      color:
                          inDeck ? Colors.black : Colors.white),
                );
              }).toList(),
            ),
            const Divider(),
          ],
          // Search bar
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 8.0),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search notes…',
              ),
              onChanged: (v) =>
                  setState(() => _searchQuery = v),
            ),
          ),
          // Date-range toggles
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 4.0),
            child: ToggleButtons(
              isSelected: DateRangeFilter.values
                  .map((f) => f == _dateFilter)
                  .toList(),
              onPressed: (i) => setState(() =>
                  _dateFilter = DateRangeFilter.values[i]),
              children: const [
                Padding(
                    padding: EdgeInsets.all(8),
                    child: Text('All')),
                Padding(
                    padding: EdgeInsets.all(8),
                    child: Text('Day')),
                Padding(
                    padding: EdgeInsets.all(8),
                    child: Text('Week')),
                Padding(
                    padding: EdgeInsets.all(8),
                    child: Text('Month')),
                Padding(
                    padding: EdgeInsets.all(8),
                    child: Text('Year')),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: _filteredNotes.isEmpty
                ? const Center(
                    child:
                        Text('No matching notes.'),
                  )
                : ListView.builder(
                    itemCount: _filteredNotes.length,
                    itemBuilder: (_, i) {
                      final note =
                          _filteredNotes[i];
                      final selected =
                          _selectedIds.contains(
                              note.id);
                      final proj = note.projectId !=
                              null
                          ? _projSvc.getById(
                              note.projectId!)
                          : null;
                      return ListTile(
                        selected: selected,
                        selectedTileColor:
                            Colors.deepPurple.shade50,
                        leading: _selectionMode
                            ? Checkbox(
                                value: selected,
                                onChanged: (_) =>
                                    _toggleSelect(
                                        note.id),
                              )
                            : null,
                        title: Text(note.title.isEmpty
                            ? '(No Title)'
                            : note.title),
                        subtitle: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            Text(
                              note.content,
                              maxLines: 1,
                              overflow:
                                  TextOverflow
                                      .ellipsis,
                            ),
                            if (proj != null)
                              Text(
                                'Project: ${proj.title}',
                                style:
                                    const TextStyle(
                                  fontSize: 12,
                                  fontStyle:
                                      FontStyle
                                          .italic,
                                ),
                              ),
                            Text(
                              DateFormat.yMMMd()
                                  .add_jm()
                                  .format(note
                                      .lastUpdated),
                              style: const TextStyle(
                                  fontSize: 10),
                            ),
                          ],
                        ),
                        onLongPress: () =>
                            _enterSelection(
                                note.id),
                        onTap: _selectionMode
                            ? () =>
                                _toggleSelect(
                                    note.id)
                            : () =>
                                Navigator.of(context)
                                    .push(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            NoteDetailPage(
                                                omniNote:
                                                    note),
                                      ),
                                    )
                                    .then((_) =>
                                        setState(() {})),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: _realmFilter != null
          ? FloatingActionButton.extended(
              icon: const Icon(Icons.filter_alt),
              label: Text(
                  'Draw ${_realmFilter!.displayName} Spirit'),
              onPressed: _drawRealmSpirit,
            )
          : _selectionMode
              ? null
              : FloatingActionButton(
                  onPressed: () => Navigator.of(context)
                      .push(MaterialPageRoute(
                        builder: (_) =>
                            const NoteDetailPage(),
                      ))
                      .then((_) => setState(() {})),
                  child: const Icon(Icons.add),
                ),
    );
  }
}
