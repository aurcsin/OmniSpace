// File: lib/pages/time_group_journal_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/omni_note.dart';
import '../services/omni_note_service.dart';
import '../widgets/main_menu_drawer.dart';
import 'note_detail_page.dart';
import 'note_view_page.dart';

class TimeGroupJournalPage extends StatefulWidget {
  const TimeGroupJournalPage({super.key});

  @override
  _TimeGroupJournalPageState createState() => _TimeGroupJournalPageState();
}

class _TimeGroupJournalPageState extends State<TimeGroupJournalPage> {
  bool _isLoading = true;
  Map<String, List<OmniNote>> _grouped = {};

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    await OmniNoteService.instance.loadAllNotes();
    final notes = OmniNoteService.instance.notes;
    notes.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final Map<String, List<OmniNote>> grouped = {};
    for (var n in notes) {
      final key = DateFormat('yyyy-MM-dd').format(n.createdAt);
      grouped.putIfAbsent(key, () => []).add(n);
    }

    setState(() {
      _grouped = grouped;
      _isLoading = false;
    });
  }

  String _formatZone(ZoneTheme zone) => zone.name;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MainMenuDrawer(),
      appBar: AppBar(title: const Text('Time-Grouped Journal')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _grouped.isEmpty
              ? const Center(child: Text('No notes yet.'))
              : ListView(
                  children: _grouped.entries.map((entry) {
                    final displayDate = DateFormat('MMM d, yyyy')
                        .format(DateTime.parse(entry.key));
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(
                            displayDate,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        ...entry.value.map((note) {
                          return ListTile(
                            title: Text(
                              note.title.isNotEmpty ? note.title : '(No Title)',
                            ),
                            subtitle: Text(note.subtitle),
                            trailing: Text(_formatZone(note.zone)),
                            onTap: () => Navigator.of(context)
                                .push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        NoteViewPage(note: note),
                                  ),
                                )
                                .then((_) => _loadNotes()),
                          );
                        }),
                      ],
                    );
                  }).toList(),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context)
            .push(
              MaterialPageRoute(
                builder: (_) => const NoteDetailPage(omniNote: null),
              ),
            )
            .then((_) => _loadNotes()),
        child: const Icon(Icons.add),
      ),
    );
  }
}
