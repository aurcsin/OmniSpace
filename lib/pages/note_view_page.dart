// File: lib/pages/note_view_page.dart

import 'package:flutter/material.dart';
import '../models/omni_note.dart';
import '../services/omni_note_service.dart';
import '../widgets/main_menu_drawer.dart';
import '../widgets/object_card.dart';
import 'note_detail_page.dart';

class NoteViewPage extends StatefulWidget {
  final OmniNote note;
  const NoteViewPage({Key? key, required this.note}) : super(key: key);

  @override
  _NoteViewPageState createState() => _NoteViewPageState();
}

class _NoteViewPageState extends State<NoteViewPage>
    with SingleTickerProviderStateMixin {
  late OmniNote _note;

  @override
  void initState() {
    super.initState();
    _note = widget.note;
  }

  Future<void> _edit() async {
    // Push the detail page to edit
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => NoteDetailPage(omniNote: _note)),
    );

    // Reload from the service using the correct method
    final reloaded = OmniNoteService.instance.getById(_note.id);
    if (reloaded != null) {
      setState(() => _note = reloaded);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MainMenuDrawer(),
      appBar: AppBar(
        title: Text(_note.title.isNotEmpty ? _note.title : '(Untitled)'),
        actions: [
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
