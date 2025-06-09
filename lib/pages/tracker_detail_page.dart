// File: lib/pages/tracker_detail_page.dart

import 'package:flutter/material.dart';
import 'package:omnispace/models/tracker.dart';
import 'package:omnispace/models/tracker_type.dart';
import 'package:omnispace/models/zone_theme.dart';
import 'package:omnispace/models/omni_note.dart';
import 'package:omnispace/services/tracker_service.dart';
import 'package:omnispace/services/omni_note_service.dart';
import 'package:omnispace/pages/note_detail_page.dart';

/// Displays details for a single tracker and its linked notes.
class TrackerDetailPage extends StatefulWidget {
  final Tracker tracker;
  const TrackerDetailPage({required this.tracker, Key? key}) : super(key: key);

  @override
  _TrackerDetailPageState createState() => _TrackerDetailPageState();
}

class _TrackerDetailPageState extends State<TrackerDetailPage> {
  late Tracker _tracker;
  List<OmniNote> _linkedNotes = [];
  bool _isEditing = false;
  late TextEditingController _titleController;

  @override
  void initState() {
    super.initState();
    _tracker = widget.tracker;
    _titleController = TextEditingController(text: _tracker.title);
    _loadLinkedNotes();
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _loadLinkedNotes() async {
    final noteIds = TrackerService.instance.notesForTracker(_tracker.id);
    final allNotes = OmniNoteService.instance.notes;
    setState(() {
      _linkedNotes = allNotes.where((n) => noteIds.contains(n.id)).toList();
    });
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        // Save when exiting edit mode
        _tracker.title = _titleController.text;
        TrackerService.instance.save(_tracker);
      }
    });
  }

  void _addLinkedNote() async {
    // Create a new note, save it, then link to tracker
    final newNote = OmniNote(
      id: UniqueKey().toString(),
      title: '',
      subtitle: '',
      content: '',
      zone: _tracker.type == TrackerType.event ? ZoneTheme.Earth : ZoneTheme.Fusion,
      tags: '',
      colorValue: 0xFFFFFFFF,
      createdAt: DateTime.now(),
      lastUpdated: DateTime.now(),
      attachments: [],
    );
    await OmniNoteService.instance.saveNote(newNote);
    await TrackerService.instance.linkNote(_tracker.id, newNote.id);
    await _loadLinkedNotes();
    if (mounted) {
      Navigator.of(context)
          .push(MaterialPageRoute(
              builder: (_) => NoteDetailPage(omniNote: newNote)))
          .then((_) => _loadLinkedNotes());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isEditing
            ? TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: 'Tracker Title',
                ),
              )
            : Text(_tracker.title),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.check : Icons.edit),
            onPressed: _toggleEdit,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Linked Notes',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addLinkedNote,
                  tooltip: 'Add & link new note',
                ),
              ],
            ),
          ),
          Expanded(
            child: _linkedNotes.isEmpty
                ? const Center(child: Text('No notes linked to this tracker.'))
                : ListView.builder(
                    itemCount: _linkedNotes.length,
                    itemBuilder: (context, index) {
                      final note = _linkedNotes[index];
                      return ListTile(
                        title: Text(
                            note.title.isNotEmpty ? note.title : '(No Title)'),
                        subtitle: Text(
                          note.content.length > 50
                              ? '${note.content.substring(0, 50)}...'
                              : note.content,
                        ),
                        onTap: () => Navigator.of(context)
                            .push(MaterialPageRoute(
                                builder: (_) => NoteDetailPage(omniNote: note)))
                            .then((_) => _loadLinkedNotes()),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
