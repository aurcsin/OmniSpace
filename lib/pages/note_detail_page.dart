// lib/pages/note_detail_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:omnispace/models/omni_note.dart';
import 'package:omnispace/models/project.dart';
import 'package:omnispace/models/spirit.dart';
import 'package:omnispace/models/tracker.dart';
import 'package:omnispace/models/note_collection.dart';
import 'package:omnispace/models/zone_theme.dart';

import 'package:omnispace/services/omni_note_service.dart';
import 'package:omnispace/services/project_service.dart';
import 'package:omnispace/services/spirit_service.dart';
import 'package:omnispace/services/tracker_service.dart';
import 'package:omnispace/services/note_collection_service.dart';

import 'package:omnispace/widgets/help_button.dart';
import 'package:omnispace/widgets/main_menu_drawer.dart';

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
  final _trackSvc  = TrackerService.instance;
  final _collSvc   = NoteCollectionService.instance;

  late OmniNote _note;
  late TextEditingController _titleCtl;
  late TextEditingController _contentCtl;

  static const Map<String, ZoneTheme> _moodMap = {
    'Calm':        ZoneTheme.Water,
    'Energetic':   ZoneTheme.Fire,
    'Focused':     ZoneTheme.Air,
    'Grounded':    ZoneTheme.Earth,
    'Curious':     ZoneTheme.Void,
    'Fusion Flow': ZoneTheme.Fusion,
  };

  @override
  void initState() {
    super.initState();
    _note = widget.omniNote ??
        OmniNote(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: '',
          subtitle: '',
          content: '',
          zone: ZoneTheme.Fusion,
          tags: '',
          colorValue: 0xFFFFFFFF,
        );
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
    Navigator.of(context).pop(true);
  }

  void _cancel() => Navigator.of(context).pop(false);

  Future<void> _toggleStar() async {
    _note.isStarred = !_note.isStarred;
    await _noteSvc.save(_note);
    setState(() {});
  }

  Future<void> _toggleLock() async {
    if (_note.isLocked) {
      final pw = await _prompt('Unlock Note', 'Password');
      if (pw == _note.lockPassword) {
        _note.isLocked = false;
        await _noteSvc.save(_note);
        setState(() {});
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Wrong password')));
      }
    } else {
      final pw = await _prompt('Lock Note', 'Set password');
      if (pw != null && pw.isNotEmpty) {
        _note
          ..isLocked = true
          ..lockPassword = pw;
        await _noteSvc.save(_note);
        setState(() {});
      }
    }
  }

  Future<String?> _prompt(String title, String label) {
    final ctl = TextEditingController();
    return showDialog<String?>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: ctl,
          obscureText: true,
          decoration: InputDecoration(labelText: label),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, ctl.text), child: const Text('OK')),
        ],
      ),
    );
  }

  Future<void> _assign<T>({
    required String title,
    required List<T> items,
    required String? selectedId,
    required String? Function(T) idOf,
    required String Function(T) display,
    required void Function(String?) onSave,
  }) async {
    final id = await showModalBottomSheet<String?>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(title: Text('Assign $title')),
          ...items.map((i) {
            final iid = idOf(i);
            return RadioListTile<String?>(
              value: iid,
              groupValue: selectedId,
              title: Text(display(i)),
              onChanged: (v) => Navigator.pop(context, v),
            );
          }).toList(),
          RadioListTile<String?>(
            value: null,
            groupValue: selectedId,
            title: const Text('None'),
            onChanged: (v) => Navigator.pop(context, v),
          ),
        ]),
      ),
    );
    if (id != null || selectedId != null) {
      onSave(id);
      await _noteSvc.save(_note);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final locked = _note.isLocked;

    return Scaffold(
      drawer: const MainMenuDrawer(),
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.close), onPressed: _cancel),
        title: Text(locked
            ? 'Locked'
            : (_note.title.isEmpty ? 'New Note' : 'Edit Note')),
        actions: [
          HelpButton(helpTitle: 'Note Help', helpText: 'Star, lock, assign & save/cancel.'),
          IconButton(
              icon: Icon(_note.isStarred ? Icons.star : Icons.star_border),
              onPressed: locked ? null : _toggleStar),
          IconButton(
              icon: Icon(_note.isLocked ? Icons.lock : Icons.lock_open),
              onPressed: _toggleLock),
          if (!locked)
            IconButton(icon: const Icon(Icons.save), onPressed: _saveNote),
        ],
      ),
      body: locked
          ? Center(
              child: TextButton.icon(
                icon: const Icon(Icons.lock_open),
                label: const Text('Unlock'),
                onPressed: _toggleLock,
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _titleCtl,
                      decoration: const InputDecoration(hintText: 'Title…'),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      DateFormat.yMMMd().add_jm().format(_note.lastUpdated),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 16),

                    // Mood → Zone
                    DropdownButtonFormField<String?>(
                      value: _note.mood,
                      decoration: const InputDecoration(labelText: 'Mood'),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('None')),
                        ..._moodMap.keys
                            .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                            .toList(),
                      ],
                      onChanged: (m) {
                        _note.mood = m;
                        _note.zone = m == null ? ZoneTheme.Fusion : _moodMap[m]!;
                        _noteSvc.save(_note);
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: 8),

                    // Assign buttons
                    Wrap(spacing: 8, children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.folder_open),
                        label: const Text('Project'),
                        onPressed: () => _assign<Project>(
                          title: 'Project',
                          items: _projSvc.all,
                          selectedId: _note.projectId,
                          idOf: (p) => (p as Project).id,
                          display: (p) => (p as Project).title,
                          onSave: (v) => _note.projectId = v,
                        ),
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.nature),
                        label: const Text('Spirit'),
                        onPressed: () => _assign<Spirit>(
                          title: 'Spirit',
                          items: _spiritSvc.getCollectibles(),
                          selectedId: _note.linkedSpiritId,
                          idOf: (s) => (s as Spirit).id,
                          display: (s) => (s as Spirit).name,
                          onSave: (v) => _note.linkedSpiritId = v,
                        ),
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.track_changes),
                        label: const Text('Tracker'),
                        onPressed: () => _assign<Tracker>(
                          title: 'Tracker',
                          items: _trackSvc.all,
                          selectedId: _note.linkedTrackerId,
                          idOf: (t) => (t as Tracker).id,
                          display: (t) => (t as Tracker).title,
                          onSave: (v) => _note.linkedTrackerId = v,
                        ),
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.collections_bookmark),
                        label: const Text('Collection'),
                        onPressed: () => _assign<NoteCollection>(
                          title: 'Collection',
                          items: _collSvc.all,
                          selectedId: _note.linkedCollectionId,
                          idOf: (c) => (c as NoteCollection).id,
                          display: (c) => (c as NoteCollection).name,
                          onSave: (v) => _note.linkedCollectionId = v,
                        ),
                      ),
                    ]),

                    const SizedBox(height: 16),
                    Expanded(
                      child: TextField(
                        controller: _contentCtl,
                        decoration: const InputDecoration(
                          hintText: 'Content…',
                          border: OutlineInputBorder(),
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
