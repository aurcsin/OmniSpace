// lib/pages/note_detail_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/omni_note.dart';
import '../services/omni_note_service.dart';
import '../services/ai_service.dart';

class NoteDetailPage extends StatefulWidget {
  /// If omniNote is null, we are creating a new note.
  /// Otherwise, we are editing an existing note.
  final OmniNote? omniNote;

  const NoteDetailPage({Key? key, this.omniNote}) : super(key: key);

  @override
  _NoteDetailPageState createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends State<NoteDetailPage> {
  final _formKey = GlobalKey<FormState>();

  late String _title;
  late String _subtitle;
  late String _content;
  late ZoneTheme _selectedZone;
  String? _selectedRecommendedTag;
  List<String> _customTagList = [];

  bool _isGeneratingTag = false;
  List<String> _recommendedTagOptions = [];

  final _contentController = TextEditingController();
  final _tagsController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.omniNote != null) {
      // Pre-populate fields for editing
      _title = widget.omniNote!.title;
      _subtitle = widget.omniNote!.subtitle;
      _content = widget.omniNote!.content;
      _selectedZone = widget.omniNote!.zone;
      _selectedRecommendedTag = widget.omniNote!.recommendedTag;
      _customTagList = widget.omniNote!.tags.split(',').where((s) => s.isNotEmpty).toList();
      _contentController.text = _content;
      _tagsController.text = widget.omniNote!.tags;
    } else {
      // Defaults for a new note
      _title = '';
      _subtitle = '';
      _content = '';
      _selectedZone = ZoneTheme.Fusion;
      _selectedRecommendedTag = null;
      _customTagList = [];
    }

    // As user types content, generate an AI tag (only override for new notes)
    _contentController.addListener(() async {
      final text = _contentController.text.trim();
      if (text.length > 5) {
        setState(() => _isGeneratingTag = true);
        final aiTag = await AIService.instance.generateRecommendedTag(text);
        setState(() {
          _isGeneratingTag = false;
          _recommendedTagOptions = aiTag != null ? [aiTag] : [];
          if (widget.omniNote == null) {
            // Only override for brand-new notes
            _selectedRecommendedTag = aiTag;
          }
        });
      } else if (widget.omniNote == null) {
        setState(() {
          _recommendedTagOptions = [];
          _selectedRecommendedTag = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _contentController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final noteService = Provider.of<OmniNoteService>(context, listen: false);
    final isEditing = widget.omniNote != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Note' : 'New Note'),
        actions: [
          if (isEditing)
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () async {
                await noteService.deleteNote(widget.omniNote!);
                Navigator.of(context).pop();
              },
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1) Title
              TextFormField(
                initialValue: _title,
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: UnderlineInputBorder(),
                ),
                onChanged: (val) => _title = val.trim(),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              SizedBox(height: 12),

              // 2) Subtitle (optional)
              TextFormField(
                initialValue: _subtitle,
                decoration: InputDecoration(
                  labelText: 'Subtitle (optional)',
                  border: UnderlineInputBorder(),
                ),
                onChanged: (val) => _subtitle = val.trim(),
              ),
              SizedBox(height: 12),

              // 3) Content
              TextFormField(
                controller: _contentController,
                decoration: InputDecoration(
                  labelText: 'Content',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 6,
                minLines: 4,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter some content';
                  }
                  return null;
                },
                onChanged: (val) => _content = val.trim(),
              ),
              SizedBox(height: 12),

              // 4) Zone Theme dropdown
              DropdownButtonFormField<ZoneTheme>(
                decoration: InputDecoration(
                  labelText: 'Select a zone theme',
                  border: UnderlineInputBorder(),
                ),
                value: _selectedZone,
                items: ZoneTheme.values.map((zone) {
                  return DropdownMenuItem(
                    value: zone,
                    child: Text(_formatZone(zone)),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedZone = val);
                },
              ),
              SizedBox(height: 12),

              // 5) Recommended Tag (AI)
              InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Select recommended tag',
                  border: UnderlineInputBorder(),
                ),
                child: _isGeneratingTag
                    ? Row(
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 8),
                          Text('Generating…'),
                        ],
                      )
                    : (_recommendedTagOptions.isEmpty
                        ? Text(
                            isEditing && _selectedRecommendedTag != null
                                ? _selectedRecommendedTag!
                                : '–',
                            style: TextStyle(color: Colors.grey[600]),
                          )
                        : DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedRecommendedTag,
                              isDense: true,
                              items: _recommendedTagOptions.map((tag) {
                                return DropdownMenuItem(
                                  value: tag,
                                  child: Text(tag),
                                );
                              }).toList(),
                              onChanged: (val) => setState(() {
                                _selectedRecommendedTag = val;
                              }),
                            ),
                          )),
              ),
              SizedBox(height: 12),

              // 6) Custom Tags (comma-separated)
              TextFormField(
                controller: _tagsController,
                decoration: InputDecoration(
                  labelText: 'Tags (comma-separated)',
                  border: UnderlineInputBorder(),
                  hintText: 'e.g. sadness, Project:Axiality',
                ),
                onChanged: (val) {
                  final parts = val
                      .split(',')
                      .map((s) => s.trim())
                      .where((s) => s.isNotEmpty)
                      .toList();
                  setState(() => _customTagList = parts);
                },
              ),
              SizedBox(height: 24),

              // 7) Save button
              ElevatedButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;

                  final tagsAsString = _customTagList.join(',');

                  if (isEditing) {
                    final updatedNote = widget.omniNote!
                      ..title = _title
                      ..subtitle = _subtitle
                      ..content = _content
                      ..zone = _selectedZone
                      ..recommendedTag = _selectedRecommendedTag
                      ..tags = tagsAsString;
                    await OmniNoteService.instance.updateNote(updatedNote);
                  } else {
                    final newNote = OmniNote(
                      title: _title,
                      subtitle: _subtitle,
                      content: _content,
                      zone: _selectedZone,
                      recommendedTag: _selectedRecommendedTag,
                      tags: tagsAsString,
                    );
                    await OmniNoteService.instance.createNote(newNote);
                  }

                  Navigator.of(context).pop();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child:
                      Text(isEditing ? 'Update' : 'Save', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatZone(ZoneTheme zone) {
    switch (zone) {
      case ZoneTheme.Air:
        return 'Air (Sky)';
      case ZoneTheme.Earth:
        return 'Earth (Garden)';
      case ZoneTheme.Fire:
        return 'Fire (Workshop)';
      case ZoneTheme.Water:
        return 'Water (Studio)';
      case ZoneTheme.Void:
        return 'Void (Root Cave)';
      case ZoneTheme.Fusion:
        return 'Fusion (Journal)';
    }
  }
}
