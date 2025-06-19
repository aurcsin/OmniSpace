// File: lib/pages/journal_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/omni_note.dart';
import '../models/project.dart';
import '../services/omni_note_service.dart';
import '../services/project_service.dart';
import '../widgets/main_menu_drawer.dart';
import '../widgets/search_filter_bar.dart';
import '../services/search_filter_service.dart';
import 'note_detail_page.dart';

class JournalPage extends StatefulWidget {
  const JournalPage({Key? key}) : super(key: key);

  @override
  State<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  final _filter = SearchFilterService.instance;
  Set<String> _selected = {};

  @override
  void initState() {
    super.initState();
    OmniNoteService.instance.addListener(() => setState(() {}));
    _filter.addListener(() => setState(() {}));
  }

  void _toggleSelect(String id) {
    setState(() {
      if (!_selected.remove(id)) _selected.add(id);
    });
  }

  Future<void> _batchAddToProject() async {
    final projId = await showModalBottomSheet<String>(
      context: context,
      builder: (_) {
        final all = ProjectService.instance.all;
        return ListView(
          children: [
            ...all.map((p) => ListTile(
                  title: Text(p.title),
                  onTap: () => Navigator.pop(context, p.id),
                )),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('New Project'),
              onTap: () async {
                final ctrl = TextEditingController();
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('New Project'),
                    content: TextField(
                      controller: ctrl,
                      decoration: const InputDecoration(labelText: 'Name'),
                    ),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(_, false),
                          child: const Text('Cancel')),
                      ElevatedButton(
                          onPressed: () => Navigator.pop(_, true),
                          child: const Text('Create')),
                    ],
                  ),
                );
                if (ok == true && ctrl.text.trim().isNotEmpty) {
                  final p = Project(
                      id: UniqueKey().toString(),
                      title: ctrl.text.trim(),
                      noteIds: []);
                  await ProjectService.instance.save(p);
                  Navigator.pop(context, p.id);
                }
              },
            ),
          ],
        );
      },
    );
    if (projId != null) {
      await ProjectService.instance
          .addNotesToProject(projId, _selected.toList());
      setState(() => _selected.clear());
    }
  }

  @override
  Widget build(BuildContext context) {
    final allNotes = OmniNoteService.instance.notes;
    final notes = allNotes.where((n) {
      final q = _filter.query.toLowerCase();
      if (q.isNotEmpty &&
          !('${n.title} ${n.content}'.toLowerCase().contains(q))) {
        return false;
      }
      final date = n.createdAt;
      final f = _filter.focusDate;
      switch (_filter.viewMode) {
        case ViewMode.day:
          return date.year == f.year &&
              date.month == f.month &&
              date.day == f.day;
        case ViewMode.week:
          final start = f.subtract(const Duration(days: 3));
          final end = f.add(const Duration(days: 3));
          return date.isAfter(start) && date.isBefore(end);
        case ViewMode.month:
          return date.year == f.year && date.month == f.month;
        case ViewMode.year:
          return date.year == f.year;
      }
    }).toList();

    return Scaffold(
      drawer: const MainMenuDrawer(),
      appBar: AppBar(
        title: _selected.isEmpty
            ? const Text('Journal')
            : Text('${_selected.length} selected'),
        leading: _selected.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => setState(() => _selected.clear()),
              ),
        actions: [
          if (_selected.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.playlist_add),
              tooltip: 'Add to Project',
              onPressed: _batchAddToProject,
            ),
        ],
      ),
      body: Column(
        children: [
          const SearchFilterBar(),
          Expanded(
            child: notes.isEmpty
                ? const Center(child: Text('No notes match your criteria.'))
                : ListView.builder(
                    itemCount: notes.length,
                    itemBuilder: (_, i) {
                      final n = notes[i];
                      final selected = _selected.contains(n.id);
                      final proj = n.projectId != null
                          ? ProjectService.instance.getById(n.projectId!)
                          : null;
                      return InkWell(
                        onLongPress: () => _toggleSelect(n.id),
                        onTap: selected
                            ? () => _toggleSelect(n.id)
                            : () => Navigator.of(context)
                                .push(MaterialPageRoute(
                                    builder: (_) =>
                                        NoteDetailPage(omniNote: n)))
                                .then((_) => setState(() {})),
                        child: ListTile(
                          leading: _selected.isEmpty
                              ? null
                              : Checkbox(
                                  value: selected,
                                  onChanged: (_) => _toggleSelect(n.id),
                                ),
                          title: Text(
                              n.title.isEmpty ? '(No Title)' : n.title),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(n.content,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                              if (proj != null)
                                Text(
                                  'Project: ${proj.title}',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontStyle: FontStyle.italic),
                                ),
                              Text(
                                DateFormat.yMMMd()
                                    .add_jm()
                                    .format(n.lastUpdated),
                                style: const TextStyle(fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: _selected.isEmpty
          ? FloatingActionButton(
              onPressed: () => Navigator.of(context)
                  .push(MaterialPageRoute(
                      builder: (_) => const NoteDetailPage()))
                  .then((_) => setState(() {})),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
