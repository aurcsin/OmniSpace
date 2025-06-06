import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:omnispace/models/omni_note.dart';

class NoteDetailPage extends StatefulWidget {
  final OmniNote? note;

  const NoteDetailPage({Key? key, this.note}) : super(key: key);

  @override
  State<NoteDetailPage> createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends State<NoteDetailPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(text: widget.note?.content ?? '');
  }

  void _saveNote() async {
    if (_formKey.currentState!.validate()) {
      final noteBox = Hive.box<OmniNote>('omni_notes');

      final note = widget.note ??
          OmniNote(
            title: '',
            subtitle: '',
            content: '',
            tags: '',
            createdAt: DateTime.now(),
            zoneTheme: '',
          );

      note
        ..title = _titleController.text
        ..content = _contentController.text
        ..createdAt = DateTime.now();

      if (note.isInBox) {
        await note.save();
      } else {
        await noteBox.add(note);
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note == null ? 'New Note' : 'Edit Note'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveNote,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(labelText: 'Content'),
                maxLines: 8,
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
