import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:omnispace/models/omni_note.dart';
import 'package:omnispace/pages/note_detail_page.dart';

class TimeGroupJournalPage extends StatelessWidget {
  const TimeGroupJournalPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final box = Hive.isBoxOpen('omni_notes')
        ? Hive.box<OmniNote>('omni_notes')
        : null;

    if (box == null) {
      return const Scaffold(
        body: Center(child: Text('Error: Hive box not open.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Journal Entries')),
      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box<OmniNote> box, _) {
          if (box.values.isEmpty) {
            return const Center(child: Text("No notes yet."));
          }

          final List<OmniNote> notes = box.values.toList();
          notes.sort((a, b) => b.createdAt.compareTo(a.createdAt));

          final Map<String, List<OmniNote>> grouped = {};

          for (var note in notes) {
            final date = note.createdAt;
            final key = DateFormat('yyyy-MM-dd').format(date);
            grouped.putIfAbsent(key, () => []).add(note);
          }

          return ListView(
            children: grouped.entries.map((entry) {
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
                      title: Text(note.title),
                      subtitle: Text(note.subtitle),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => NoteDetailPage(note: note),
                        ),
                      ),
                    );
                  }).toList(),
                ],
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NoteDetailPage()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
