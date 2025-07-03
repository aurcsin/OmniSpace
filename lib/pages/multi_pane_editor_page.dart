// File: lib/pages/multi_pane_editor_page.dart

import 'dart:async';

import 'package:flutter/foundation.dart'; // for describeEnum
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/omni_note.dart';
import '../models/zone_theme.dart';
import '../services/omni_note_service.dart';

class MultiPaneEditorPage extends StatefulWidget {
  final OmniNote note;
  const MultiPaneEditorPage(this.note, {Key? key}) : super(key: key);

  @override
  _MultiPaneEditorPageState createState() => _MultiPaneEditorPageState();
}

class _MultiPaneEditorPageState extends State<MultiPaneEditorPage> {
  late OmniNote _note;
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _tagsController;
  Timer? _saveDebounce;

  @override
  void initState() {
    super.initState();
    _note = widget.note;
    _titleController = TextEditingController(text: _note.title)
      ..addListener(_onTitleChanged);
    _contentController = TextEditingController(text: _note.content)
      ..addListener(_onContentChanged);
    _tagsController = TextEditingController(text: _note.tags);
  }

  @override
  void dispose() {
    _saveDebounce?.cancel();
    _titleController.dispose();
    _contentController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  void _onTitleChanged() {
    _note.title = _titleController.text;
    _scheduleSave();
  }

  void _onContentChanged() {
    _note.content = _contentController.text;
    _scheduleSave();
  }

  void _scheduleSave() {
    _note.lastUpdated = DateTime.now();
    _saveDebounce?.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 500), () {
      OmniNoteService.instance.saveNote(_note);
    });
  }

  void _togglePin() {
    setState(() {
      _note.isPinned = !_note.isPinned;
      OmniNoteService.instance.saveNote(_note);
    });
  }

  void _toggleArchive() {
    setState(() {
      _note.isArchived = !_note.isArchived;
      OmniNoteService.instance.saveNote(_note);
    });
  }

  void _changeZone(ZoneTheme? newZone) {
    if (newZone == null) return;
    setState(() {
      _note.zone = newZone;
      OmniNoteService.instance.saveNote(_note);
    });
  }

  void _onTagsSubmitted(String v) {
    _note.tags = v;
    OmniNoteService.instance.saveNote(_note);
  }

  Widget _buildMetadataPane() {
    return Container(
      width: 260,
      color: Colors.grey.shade100,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Metadata',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<ZoneTheme>(
            value: _note.zone,
            decoration: const InputDecoration(labelText: 'Zone'),
            items: ZoneTheme.values
                .map((z) => DropdownMenuItem(
                      value: z,
                      child: Text(describeEnum(z)),
                    ))
                .toList(),
            onChanged: _changeZone,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _tagsController,
            decoration: const InputDecoration(labelText: 'Tags (comma)'),
            onSubmitted: _onTagsSubmitted,
          ),
          const SizedBox(height: 12),
          Text(
            'Created: ${DateFormat.yMMMd().add_jm().format(_note.createdAt)}',
            style: const TextStyle(fontSize: 12),
          ),
          Text(
            'Updated: ${DateFormat.yMMMd().add_jm().format(_note.lastUpdated)}',
            style: const TextStyle(fontSize: 12),
          ),
          const Spacer(),
          Row(
            children: [
              IconButton(
                icon: Icon(
                    _note.isPinned ? Icons.push_pin : Icons.push_pin_outlined),
                tooltip: _note.isPinned ? 'Unpin' : 'Pin',
                onPressed: _togglePin,
              ),
              IconButton(
                icon: Icon(_note.isArchived
                    ? Icons.unarchive
                    : Icons.archive_outlined),
                tooltip: _note.isArchived ? 'Unarchive' : 'Archive',
                onPressed: _toggleArchive,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEditorPane() {
    return Expanded(
      flex: 2,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: TextField(
          controller: _contentController,
          maxLines: null,
          expands: true,
          textAlignVertical: TextAlignVertical.top,
          decoration: const InputDecoration(
            border: InputBorder.none,
            hintText: 'Write your note here…',
          ),
        ),
      ),
    );
  }

  String _generateSummary() {
    final text = _note.content.trim();
    if (text.length < 100) return text;
    return '${text.substring(0, 100)}…';
  }

  Widget _buildAIPane() {
    return Container(
      width: 260,
      color: Colors.grey.shade50,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('AI Insights',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          const Text('Auto-Summary:',
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(_generateSummary()),
          const SizedBox(height: 16),
          const Text('Suggestions:', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          const BulletText('What feelings come up when reading this?'),
          const BulletText('Could you break this into subsections?'),
          const BulletText('What’s the next action step?'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;
    if (isMobile) {
      return DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: Text(_note.title.isEmpty ? 'Untitled' : _note.title),
            bottom: const TabBar(tabs: [
              Tab(icon: Icon(Icons.info_outline)),
              Tab(icon: Icon(Icons.edit)),
              Tab(icon: Icon(Icons.smart_toy)),
            ]),
          ),
          body: TabBarView(children: [
            _buildMetadataPane(),
            _buildEditorPane(),
            _buildAIPane(),
          ]),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(_note.title.isEmpty ? 'Untitled' : _note.title),
      ),
      body: Row(
        children: [
          _buildMetadataPane(),
          const VerticalDivider(width: 1),
          _buildEditorPane(),
          const VerticalDivider(width: 1),
          _buildAIPane(),
        ],
      ),
    );
  }
}

class BulletText extends StatelessWidget {
  final String text;
  const BulletText(this.text, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(children: [
        const Text('• ', style: TextStyle(fontSize: 14)),
        Expanded(child: Text(text)),
      ]),
    );
  }
}
