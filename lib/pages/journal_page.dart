import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:omnispace/models/omni_note.dart';
import 'package:omnispace/pages/note_detail_page.dart';

class JournalPage extends StatefulWidget {
  const JournalPage({Key? key}) : super(key: key);

  @override
  State<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  // Note: box name must match what main.dart opened ("omni_notes")
  final Box<OmniNote> notesBox = Hive.box<OmniNote>('omni_notes');

  String selectedView = 'Daily'; // 'Daily', 'Weekly', 'Monthly', 'Yearly'
  String tagFilter = '';

  List<OmniNote> getFilteredNotes() {
    var notes = notesBox.values.toList();

    // Filter by tag (case‐insensitive)
    if (tagFilter.isNotEmpty) {
      notes = notes.where((note) {
        return note.tags.toLowerCase().contains(tagFilter.toLowerCase());
      }).toList();
    }

    // Sort by lastUpdated descending (most recently edited first)
    notes.sort((a, b) => b.lastUpdated.compareTo(a.lastUpdated));
    return notes;
  }

  String formatDate(DateTime date) {
    switch (selectedView) {
      case 'Weekly':
        final start = date.subtract(Duration(days: date.weekday - 1));
        final end = start.add(const Duration(days: 6));
        return '${DateFormat.MMMd().format(start)} – ${DateFormat.MMMd().format(end)}';
      case 'Monthly':
        return DateFormat.yMMM().format(date);
      case 'Yearly':
        return DateFormat.y().format(date);
      default:
        return DateFormat.yMMMd().format(date);
    }
  }

  void _showTagFilterDialog() {
    final controller = TextEditingController(text: tagFilter);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter by Tag'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Enter tag'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => tagFilter = controller.text.trim());
              Navigator.of(context).pop();
            },
            child: const Text('Apply'),
          ),
          TextButton(
            onPressed: () {
              setState(() => tagFilter = '');
              Navigator.of(context).pop();
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _changeView(String newView) {
    setState(() => selectedView = newView);
  }

  @override
  Widget build(BuildContext context) {
    final notes = getFilteredNotes();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal'),
        actions: [
          PopupMenuButton<String>(
            onSelected: _changeView,
            itemBuilder: (context) => ['Daily', 'Weekly', 'Monthly', 'Yearly']
                .map((view) => PopupMenuItem<String>(
                      value: view,
                      child: Text(view),
                    ))
                .toList(),
          ),
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: _showTagFilterDialog,
          ),
        ],
      ),
      body: notes.isEmpty
          ? const Center(child: Text('No notes yet.'))
          : ListView.builder(
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];
                return ListTile(
                  title: Text(note.title),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (note.subtitle.isNotEmpty)
                        Text(note.subtitle,
                            style: const TextStyle(fontStyle: FontStyle.italic)),
                      if (note.tags.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text('Tags: ${note.tags}',
                              style: const TextStyle(fontSize: 12)),
                        ),
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Created: ${formatDate(note.createdAt)}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ),
                      Text(
                        'Updated: ${DateFormat.yMMMd().add_Hm().format(note.lastUpdated)}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => NoteDetailPage(note: note),
                      ),
                    ).then((_) => setState(() {}));
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NoteDetailPage()),
          ).then((_) => setState(() {}));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
