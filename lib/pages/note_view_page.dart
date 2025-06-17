import 'package:flutter/material.dart';

import '../models/omni_note.dart';
import '../widgets/object_card.dart';
import '../services/omni_note_service.dart';
import 'note_detail_page.dart';

/// Read-only view for an [OmniNote] with option to pin or edit.
class NoteViewPage extends StatefulWidget {
  final OmniNote note;
  const NoteViewPage({super.key, required this.note});

  @override
  State<NoteViewPage> createState() => _NoteViewPageState();
}

class _NoteViewPageState extends State<NoteViewPage> {
  late OmniNote _note;

  @override
  void initState() {
    super.initState();
    _note = widget.note;
  }

  Future<void> _togglePin() async {
    setState(() => _note.isPinned = !_note.isPinned);
    await OmniNoteService.instance.saveNote(_note);
  }

  Future<void> _edit() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => NoteDetailPage(omniNote: _note)),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Note'),
        actions: [
          IconButton(
            icon: Icon(_note.isPinned
                ? Icons.push_pin
                : Icons.push_pin_outlined),
            onPressed: _togglePin,
          ),
          IconButton(icon: const Icon(Icons.edit), onPressed: _edit),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: ObjectCard(note: _note),
      ),
    );
  }
}
