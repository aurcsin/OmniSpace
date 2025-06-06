import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:omnispace/models/omni_note.dart';

class NoteDetailPage extends StatefulWidget {
  final OmniNote? note;

  const NoteDetailPage({Key? key, this.note}) : super(key: key);

  @override
  State<NoteDetailPage> createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends State<NoteDetailPage> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _subtitle;
  late String _content;
  late String _tags;
  late String _zoneTheme;

  final List<String> _recommendedTags = [
    'dream',
    'reflection',
    'goal',
    'idea',
    'emotion',
    'memory'
  ];
  final List<String> _zoneThemes = [
    'Sky',
    'Garden',
    'Workshop',
    'Studio',
    'Root Cave',
    'Journal'
  ];

  // We will open the same box that main.dart did:
  late Box<OmniNote> _noteBox;

  @override
  void initState() {
    super.initState();
    _noteBox = Hive.box<OmniNote>('omni_notes');

    // Initialize fields from widget.note if editing, or default to empty for new
    _title = widget.note?.title ?? '';
    _subtitle = widget.note?.subtitle ?? '';
    _content = widget.note?.content ?? '';
    _tags = widget.note?.tags ?? '';
    _zoneTheme = widget.note?.zoneTheme ?? 'Journal';
  }

  void _saveNote() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final now = DateTime.now();

    if (widget.note == null) {
      // Create new
      final newNote = OmniNote(
        title: _title,
        subtitle: _subtitle,
        content: _content,
        tags: _tags,
        createdAt: now,
        zoneTheme: _zoneTheme,
        lastUpdated: now,
        isPinned: false,
      );
      await _noteBox.add(newNote);
    } else {
      // Update existing
      final existing = widget.note!;
      existing.title = _title;
      existing.subtitle = _subtitle;
      existing.content = _content;
      existing.tags = _tags;
      existing.zoneTheme = _zoneTheme;
      existing.lastUpdated = now;
      await existing.save();
    }

    Navigator.of(context).pop();
  }

  void _clearTags() {
    setState(() => _tags = '');
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.note != null;
    final createdAt = widget.note?.createdAt;
    final lastUpdated = widget.note?.lastUpdated;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Note' : 'New Note'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            tooltip: 'Clear Tags',
            onPressed: _clearTags,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (createdAt != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    'Created: ${DateFormat('yyyy-MM-dd – HH:mm').format(createdAt)}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ),
              if (lastUpdated != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    'Last updated: ${DateFormat('yyyy-MM-dd – HH:mm').format(lastUpdated)}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ),
              TextFormField(
                initialValue: _title,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) =>
                    (value == null || value.trim().isEmpty)
                        ? 'Please enter a title'
                        : null,
                onSaved: (value) => _title = value!.trim(),
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: _subtitle,
                decoration:
                    const InputDecoration(labelText: 'Subtitle (optional)'),
                onSaved: (value) => _subtitle = value?.trim() ?? '',
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: _content,
                decoration: const InputDecoration(labelText: 'Content'),
                maxLines: null,
                minLines: 10,
                validator: (value) =>
                    (value == null || value.trim().isEmpty)
                        ? 'Please enter content'
                        : null,
                onSaved: (value) => _content = value!.trim(),
              ),
              const SizedBox(height: 12),
              InputDecorator(
                decoration:
                    const InputDecoration(labelText: 'Select a zone theme'),
                child: DropdownButton<String>(
                  value: _zoneTheme,
                  isExpanded: true,
                  underline: const SizedBox(),
                  items: _zoneThemes
                      .map((theme) => DropdownMenuItem(
                            value: theme,
                            child: Text(theme),
                          ))
                      .toList(),
                  onChanged: (val) => setState(() => _zoneTheme = val!),
                ),
              ),
              const SizedBox(height: 12),
              InputDecorator(
                decoration:
                    const InputDecoration(labelText: 'Select recommended tag'),
                child: DropdownButton<String>(
                  hint: const Text('Choose a tag to append'),
                  isExpanded: true,
                  value: null,
                  underline: const SizedBox(),
                  items: _recommendedTags
                      .map((tag) => DropdownMenuItem(
                            value: tag,
                            child: Text(tag),
                          ))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      final tagList =
                          _tags.split(',').map((e) => e.trim()).toSet();
                      if (!tagList.contains(val)) {
                        setState(() {
                          tagList.add(val);
                          _tags = tagList.join(', ');
                        });
                      }
                    }
                  },
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: _tags,
                decoration:
                    const InputDecoration(labelText: 'Tags (comma-separated)'),
                onSaved: (value) => _tags = value?.trim() ?? '',
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveNote,
                child: Text(isEditing ? 'Save Changes' : 'Create Note'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
