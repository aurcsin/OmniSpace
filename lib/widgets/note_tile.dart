// lib/pages/note_tile.dart

import 'package:flutter/material.dart';
import '../models/omni_note.dart'; // Use a relative import instead of package:omnispace

class NoteTile extends StatelessWidget {
  final OmniNote note;

  const NoteTile({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        note.title.isNotEmpty ? note.title : '(No Title)',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        note.subtitle.isNotEmpty ? note.subtitle : '(No Subtitle)',
        style: TextStyle(color: Colors.grey[700]),
      ),
      trailing: Text(
        // Show the creation time, e.g. "12:34 PM"
        TimeOfDay.fromDateTime(note.createdAt).format(context),
        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
      ),
      onTap: () {
        // Example: navigate to detail or perform another action
        // Navigator.of(context).push(...);
      },
    );
  }
}
