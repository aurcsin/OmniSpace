// lib/pages/time_group_journal_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/omni_note.dart';
import '../services/omni_note_service.dart';
import '../widgets/main_menu_drawer.dart';
// Alias the note detail page import to avoid name collisions
import '../pages/note_detail_page.dart' as ndp;

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

  String _formatZone(ZoneTheme zone) {
    switch (zone) {
      case ZoneTheme.Air:
        return 'Air';
      case ZoneTheme.Earth:
        return 'Earth';
      case ZoneTheme.Fire:
        return 'Fire';
      case ZoneTheme.Water:
        return 'Water';
      case ZoneTheme.Void:
        return 'Void';
      case ZoneTheme.Fusion:
        return 'Fusion';
    }
  }

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
                        // Date header
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(
                            displayDate,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),

                        // Notes for this date
                        ...entry.value.map((note) {
                          return ListTile(
                            title: Text(note.title.isNotEmpty ? note.title : '(No Title)'),
                            subtitle: Text(note.subtitle),
                            trailing: Text(_formatZone(note.zone)),
                            onTap: () => Navigator.of(context)
                                .push(
                                  MaterialPageRoute(
                                    builder: (_) => ndp.NoteDetailPage(omniNote: note),
                                  ),
                                )
                                .then((_) => _loadNotes()),
                          );
                        }).toList(),
                      ],
                    );
                  }).toList(),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context)
            .push(
              MaterialPageRoute(builder: (_) => const ndp.NoteDetailPage()),
            )
            .then((_) => _loadNotes()),
        child: const Icon(Icons.add),
      ),
    );
  }
}
