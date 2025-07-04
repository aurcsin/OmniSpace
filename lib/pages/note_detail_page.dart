// lib/pages/note_detail_page.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:omnispace/models/omni_note.dart';
import 'package:omnispace/models/project.dart';
import 'package:omnispace/models/spirit.dart';
import 'package:omnispace/models/zone_theme.dart';
import 'package:omnispace/services/omni_note_service.dart';
import 'package:omnispace/services/project_service.dart';
import 'package:omnispace/services/spirit_service.dart';
import 'package:omnispace/widgets/help_button.dart';

class NoteDetailPage extends StatefulWidget {
  final OmniNote? omniNote;
  const NoteDetailPage({Key? key, this.omniNote}) : super(key: key);

  @override
  State<NoteDetailPage> createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends State<NoteDetailPage> {
  final _noteSvc   = OmniNoteService.instance;
  final _projSvc   = ProjectService.instance;
  final _spiritSvc = SpiritService.instance;

  late OmniNote _note;
  late TextEditingController _titleCtl;
  late TextEditingController _contentCtl;

  /// Map moods to elemental realms.
  static const Map<String, ZoneTheme> _moodMap = {
    'Calm': ZoneTheme.Water,
    'Energetic': ZoneTheme.Fire,
    'Focused': ZoneTheme.Air,
    'Grounded': ZoneTheme.Earth,
    'Curious': ZoneTheme.Void,
    'Fusion Flow': ZoneTheme.Fusion,
  };

  @override
  void initState() {
    super.initState();
    if (widget.omniNote != null) {
      _note = widget.omniNote!;
    } else {
      _note = OmniNote(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: '',
        subtitle: '',
        content: '',
        zone: ZoneTheme.Fusion,
        tags: '',
        colorValue: 0xFFFFFFFF,
      );
    }
    _titleCtl   = TextEditingController(text: _note.title);
    _contentCtl = TextEditingController(text: _note.content);
  }

  @override
  void dispose() {
    _titleCtl.dispose();
    _contentCtl.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    _note
      ..title       = _titleCtl.text.trim()
      ..content     = _contentCtl.text.trim()
      ..lastUpdated = DateTime.now();
    await _noteSvc.save(_note);
    Navigator.of(context).pop();
  }

  Future<void> _showAssignProjectDialog() async {
    final Project? picked = await showDialog<Project?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Assign Project'),
        content: SizedBox(
          width: 300,
          height: 400,
          child: ListView(
            children: [
              ..._projSvc.all.map((p) => ListTile(
                    title: Text(p.title),
                    selected: p.id == _note.projectId,
                    onTap: () => Navigator.pop(ctx, p),
                  )),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.add),
                title: const Text('New Project'),
                onTap: () => Navigator.pop(ctx, null),
              ),
            ],
          ),
        ),
      ),
    );

    Project toAssign;
    if (picked == null) {
      final nameCtl = TextEditingController();
      final bool? created = await showDialog<bool>(
        context: context,
        builder: (ctx2) => AlertDialog(
          title: const Text('New Project'),
          content: TextField(
            controller: nameCtl,
            decoration: const InputDecoration(labelText: 'Project Name'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx2, false), child: const Text('Cancel')),
            ElevatedButton(onPressed: () => Navigator.pop(ctx2, true), child: const Text('Create')),
          ],
        ),
      );
      if (created != true || nameCtl.text.trim().isEmpty) {
        return;
      }
      toAssign = Project(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: nameCtl.text.trim(),
        noteIds: [],
      );
      await _projSvc.save(toAssign);
    } else {
      toAssign = picked;
    }

    setState(() => _note.projectId = toAssign.id);
    await _noteSvc.save(_note);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Assigned to project “${toAssign.title}”')),
    );
  }

  Future<void> _pickSpirit() async {
    final Spirit? chosen = await showModalBottomSheet<Spirit?>(
      context: context,
      builder: (_) => SafeArea(
        child: ListView(
          children: ZoneTheme.values.map((realm) {
            final spirits = _spiritSvc.getCollectibles().where((s) => s.realm == realm);
            return ExpansionTile(
              title: Text(describeEnum(realm)),
              children: spirits.map((s) {
                return ListTile(
                  title: Text(s.name),
                  subtitle: Text(s.archetype),
                  onTap: () => Navigator.pop(context, s),
                );
              }).toList(),
            );
          }).toList(),
        ),
      ),
    );

    if (chosen != null) {
      setState(() => _note.linkedSpiritId = chosen.id);
      await _noteSvc.save(_note);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Safely lookup linked Spirit
    Spirit? spirit;
    if (_note.linkedSpiritId != null) {
      final matches = _spiritSvc.getCollectibles()
          .where((s) => s.id == _note.linkedSpiritId)
          .toList();
      if (matches.isNotEmpty) spirit = matches.first;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_note.title.isEmpty ? 'New Note' : 'Edit Note'),
        actions: [
          HelpButton(
            helpTitle: 'Note Help',
            helpText: '''
• Title your note, then reflect on your thoughts.  
• Select a Mood to tie into an element.  
• Pick a Spirit to guide you in this realm.  
• Assign to a Project if needed.  
• Tap Save when you’re done.''',
          ),
          IconButton(icon: const Icon(Icons.save), tooltip: 'Save', onPressed: _saveNote),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Title
          TextField(
            controller: _titleCtl,
            decoration: const InputDecoration(
              hintText: 'Title',
              border: UnderlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          // Timestamp
          Text(
            DateFormat.yMMMd().add_jm().format(_note.lastUpdated),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          // Mood selector
          DropdownButtonFormField<String>(
            value: _note.mood,
            decoration: const InputDecoration(labelText: 'Mood'),
            items: _moodMap.keys
                .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                .toList(),
            onChanged: (m) async {
              if (m == null) return;
              setState(() {
                _note.mood = m;
                _note.zone = _moodMap[m]!;
              });
              await _noteSvc.save(_note);
            },
          ),
          const SizedBox(height: 16),
          // Spirit picker
          Row(children: [
            const Text('Spirit:', style: TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                onPressed: _pickSpirit,
                child: Text(spirit?.name ?? 'Select Spirit'),
              ),
            ),
          ]),
          const SizedBox(height: 16),
          // Assign Project
          ElevatedButton.icon(
            icon: const Icon(Icons.folder_open),
            label: Text(
              _note.projectId == null
                  ? 'Assign Project'
                  : 'Project: ${_projSvc.getById(_note.projectId!)?.title ?? ''}',
            ),
            onPressed: _showAssignProjectDialog,
          ),
          const SizedBox(height: 16),
          // Content
          Expanded(
            child: TextField(
              controller: _contentCtl,
              decoration: const InputDecoration(
                hintText: 'Write your thoughts…',
                border: InputBorder.none,
              ),
              maxLines: null,
              expands: true,
            ),
          ),
        ]),
      ),
    );
  }
}
