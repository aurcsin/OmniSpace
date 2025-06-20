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
    OmniNoteService.instance.addListener(_loadNotes);
    _loadNotes();
  }

  @override
  void dispose() {
    OmniNoteService.instance.removeListener(_loadNotes);
    super.dispose();
  }

  Future<void> _loadNotes() async {
    setState(() => _isLoading = true);

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
                    final notesOnDate = entry.value;
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
                        ...notesOnDate.map((note) {
                          return ListTile(
                            title: Text(
                                note.title.isNotEmpty ? note.title : '(No Title)'),
                            subtitle: Text(note.subtitle),
                            trailing: Text(note.zone.name),
                            onTap: () => Navigator.of(context)
                                .push(MaterialPageRoute(
                                  builder: (_) => NoteViewPage(note: note),
                                ))
                                .then((_) => _loadNotes()),
                          );
                        }).toList(),
                        const Divider(),
                      ],
                    );
                  }).toList(),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context)
            .push(MaterialPageRoute(
              builder: (_) => const NoteDetailPage(),
            ))
            .then((_) => _loadNotes()),
        child: const Icon(Icons.add),
      ),
    );
  }
}
