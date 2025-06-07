// lib/pages/time_group_journal_page.dart

import 'package:flutter/material.dart';

import '../services/omni_note_service.dart';
import '../models/omni_note.dart';
import 'note_detail_page.dart';

class TimeGroupJournalPage extends StatelessWidget {
  const TimeGroupJournalPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // directly grab your singleton service
    final noteService = OmniNoteService.instance;
    final List<OmniNote> notes = noteService.notes;

    return Scaffold(
      appBar: AppBar(title: const Text('Time-Grouped Journal')),
      body: ListView.builder(
        itemCount: notes.length,
        itemBuilder: (context, index) {
          final note = notes[index];
          final createdAt = note.createdAt;
          final formattedDate =
              '${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.day.toString().padLeft(2, '0')}';

          return ListTile(
            title: Text(note.title),
            subtitle: Text(formattedDate),
            trailing: Text(_formatZone(note.zone)),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => NoteDetailPage(omniNote: note),
                ),
              );
            },
          );
        },
      ),
    );
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
}
