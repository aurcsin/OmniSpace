// File: lib/pages/journal_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';

import '../models/omni_note.dart';
import '../models/project.dart';
import '../models/spirit.dart';
import '../models/zone_theme.dart';
import '../services/omni_note_service.dart';
import '../services/project_service.dart';
import '../services/spirit_service.dart';
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

  Map<DateTime, int> get _heatMapData {
    final counts = <DateTime, int>{};
    for (var n in _filteredNotes) {
      final day = DateTime(n.createdAt.year, n.createdAt.month, n.createdAt.day);
      counts[day] = (counts[day] ?? 0) + 1;
    }
    return counts;
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
        final allProjects = ProjectService.instance.all;
        return AlertDialog(
          title: const Text('Add to Project'),
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
                  onTap: () async {
                    final nameCtl = TextEditingController();
                    final ok = await showDialog<bool>(
                      context: ctx,
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
                    if (ok == true && nameCtl.text.trim().isNotEmpty) {
                      final newProj = Project(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        title: nameCtl.text.trim(),
                        noteIds: [],
                      );
                      await ProjectService.instance.save(newProj);
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
        final note = OmniNoteService.instance.getNoteById(id);
        if (note != null) {
          note.projectId = proj.id;
          await OmniNoteService.instance.saveNote(note);
        }
      }
    }
    _exitSelection();
  }

  @override
  Widget build(BuildContext context) {
    final masterSpirit = SpiritService.instance.getPrimary(ZoneTheme.Fusion);
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
          if (masterSpirit != null) Padding(
            padding: const EdgeInsets.all(8),
            child: Card(
              child: ListTile(
                leading: Icon(masterSpirit.realm.icon, color: Colors.deepPurple),
                title: Text(
                  masterSpirit.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(masterSpirit.mythos),
              ),
            ),
          ),

          // Heatmap
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: HeatMapCalendar(
              colorsets: const {
                1: Colors.green,
                3: Colors.greenAccent,
                5: Colors.lightGreen,
              },
              colorMode: ColorMode.opacity,
              datasets: _heatMapData,
              initDate: DateTime.now(),
              size: 40,
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search notes…',
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),

          // Date-range toggles
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: ToggleButtons(
              isSelected: DateRangeFilter.values
                  .map((f) => f == _dateFilter)
                  .toList(),
              onPressed: (i) =>
                  setState(() => _dateFilter = DateRangeFilter.values[i]),
              children: const [
                Padding(padding: EdgeInsets.all(8), child: Text('All')),
                Padding(padding: EdgeInsets.all(8), child: Text('Day')),
                Padding(padding: EdgeInsets.all(8), child: Text('Week')),
                Padding(padding: EdgeInsets.all(8), child: Text('Month')),
                Padding(padding: EdgeInsets.all(8), child: Text('Year')),
              ],
            ),
          ),

          const Divider(),

          // Filtered List
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
                            ? Checkbox(
                                value: selected,
                                onChanged: (_) => _toggleSelect(note.id),
                              )
                            : null,
                        title: Text(
                            note.title.isEmpty ? '(No Title)' : note.title),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              note.content,
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
                                  .format(note.lastUpdated),
                              style: const TextStyle(fontSize: 10),
                            ),
                          ],
                        ),
                        onLongPress: () => _enterSelection(note.id),
                        onTap: _selectionMode
                            ? () => _toggleSelect(note.id)
                            : () => Navigator.of(context)
                                .push(MaterialPageRoute(
                                  builder: (_) =>
                                      NoteDetailPage(omniNote: note),
                                ))
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
                  .push(MaterialPageRoute(
                    builder: (_) => const NoteDetailPage(),
                  ))
                  .then((_) => setState(() {})),
              child: const Icon(Icons.add),
            ),
    );
  }
}
