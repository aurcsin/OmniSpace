// File: lib/pages/note_detail_page.dart

import 'dart:io';

import 'package:flutter/material.dart';
import '../models/omni_note.dart';
import '../models/tracker.dart';
import '../models/tracker_type.dart';
import '../services/omni_note_service.dart';
import '../services/tracker_service.dart';
import '../services/secure_storage_service.dart';
import '../widgets/main_menu_drawer.dart';
import '../utils/id_generator.dart';

/// Modes for the detail page: text, voice, image, or video.
enum NoteMode { text, voice, image, video }

class NoteDetailPage extends StatefulWidget {
  final OmniNote? omniNote;
  const NoteDetailPage({this.omniNote, super.key});

  @override
  _NoteDetailPageState createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends State<NoteDetailPage>
    with SingleTickerProviderStateMixin {
  late OmniNote _note;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleCtl, _subtitleCtl, _tagsCtl, _contentCtl;
  late ZoneTheme _zone;
  bool _lockToggle = false;
  String? _password;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();

    // Initialize or create note
    _note = widget.omniNote ??
        OmniNote(
          id: generateId(),
          title: '',
          subtitle: '',
          content: '',
          zone: ZoneTheme.Fusion,
          tags: '',
          colorValue: 0xFFFFFFFF,
          createdAt: DateTime.now(),
          lastUpdated: DateTime.now(),
        );

    // Text controllers
    _titleCtl = TextEditingController(text: _note.title);
    _subtitleCtl = TextEditingController(text: _note.subtitle);
    _tagsCtl = TextEditingController(text: _note.tags);
    _contentCtl = TextEditingController(text: _note.content);
    _zone = _note.zone;

    // Tab controller for the four tracker types
    _tabController = TabController(length: TrackerType.values.length, vsync: this)
      ..addListener(() {
        setState(() {}); // rebuild when tab changes
      });

    _initLockState();
  }

  Future<void> _initLockState() async {
    final pwd = await SecureStorageService.instance.read('lock_${_note.id}');
    setState(() {
      _lockToggle = pwd != null;
      _password = pwd;
    });
  }

  @override
  void dispose() {
    _titleCtl.dispose();
    _subtitleCtl.dispose();
    _tagsCtl.dispose();
    _contentCtl.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    if (!_formKey.currentState!.validate()) return;

    _note
      ..title = _titleCtl.text
      ..subtitle = _subtitleCtl.text
      ..tags = _tagsCtl.text
      ..content = _contentCtl.text
      ..zone = _zone
      ..lastUpdated = DateTime.now();

    await OmniNoteService.instance.saveNote(_note);

    // Persist or clear password
    final key = 'lock_${_note.id}';
    if (_lockToggle && _password?.isNotEmpty == true) {
      await SecureStorageService.instance.write(key, _password!);
    } else {
      await SecureStorageService.instance.delete(key);
    }

    Navigator.pop(context);
  }

  Future<void> _onLockToggle(bool on) async {
    if (on) {
      final ctrl = TextEditingController();
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Set Lock Password'),
          content: TextField(
            controller: ctrl,
            decoration: const InputDecoration(labelText: 'Password'),
            obscureText: true,
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('OK')),
          ],
        ),
      );
      if (ok == true && ctrl.text.isNotEmpty) {
        setState(() {
          _lockToggle = true;
          _password = ctrl.text;
        });
      }
    } else {
      setState(() {
        _lockToggle = false;
        _password = null;
      });
    }
  }

  Icon _iconForType(TrackerType type) {
    switch (type) {
      case TrackerType.goal:
        return const Icon(Icons.flag);
      case TrackerType.task:
        return const Icon(Icons.check_box);
      case TrackerType.event:
        return const Icon(Icons.event);
      case TrackerType.series:
        return const Icon(Icons.link);
    }
  }

  Future<void> _addTracker(TrackerType type) async {
    final existing = TrackerService.instance.all.where((t) => t.type == type).toList();
    final selected = await showModalBottomSheet<Tracker>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.add),
              title: Text('Create new ${type.name}'),
              onTap: () => Navigator.pop(ctx, null),
            ),
            const Divider(),
            for (var t in existing)
              ListTile(
                leading: _iconForType(t.type),
                title: Text(t.title),
                onTap: () => Navigator.pop(ctx, t),
              ),
          ],
        ),
      ),
    );

    if (selected == null) {
      final newTracker = await showDialog<Tracker>(
        context: context,
        builder: (_) => _QuickTrackerDialog(type: type),
      );
      if (newTracker != null) {
        await TrackerService.instance.create(newTracker);
        await TrackerService.instance.linkNote(newTracker.id, _note.id);
      }
    } else {
      await TrackerService.instance.linkNote(selected.id, _note.id);
    }
    setState(() {});
  }

  Future<void> _removeTracker(Tracker t) async {
    await TrackerService.instance.unlinkNote(t.id, _note.id);
    setState(() {});
  }

  Widget _buildTrackerList(TrackerType type) {
    final list = TrackerService.instance
        .trackersForNote(_note.id)
        .where((t) => t.type == type)
        .toList();
    return ReorderableListView.builder(
      onReorder: (oldIndex, newIndex) async {
        if (oldIndex < newIndex) newIndex -= 1;
        final t = list.removeAt(oldIndex);
        list.insert(newIndex, t);
        await TrackerService.instance.unlinkNote(t.id, _note.id);
        for (var tracker in list) {
          await TrackerService.instance.linkNote(tracker.id, _note.id);
        }
        setState(() {});
      },
      itemCount: list.length,
      itemBuilder: (ctx, i) {
        final t = list[i];
        return ListTile(
          key: ValueKey(t.id),
          leading: _iconForType(t.type),
          title: Text(t.title),
          trailing: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => _removeTracker(t),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MainMenuDrawer(),
      appBar: AppBar(
        title: Text(widget.omniNote == null ? 'New Note' : 'Edit Note'),
        actions: [IconButton(icon: const Icon(Icons.save), onPressed: _saveNote)],
      ),
      body: _lockToggle
          ? const Center(child: Text('🔒 Note is Locked', style: TextStyle(fontSize: 24)))
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _titleCtl,
                                decoration: const InputDecoration(labelText: 'Title'),
                                validator: (v) =>
                                    (v == null || v.isEmpty) ? 'Required' : null,
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _subtitleCtl,
                                decoration: const InputDecoration(labelText: 'Subtitle'),
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _tagsCtl,
                                decoration: const InputDecoration(
                                  labelText: 'Tags (comma-separated)',
                                  prefixText: '#',
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _contentCtl,
                                decoration: const InputDecoration(labelText: 'Content'),
                                maxLines: 6,
                              ),
                              const SizedBox(height: 12),
                              DropdownButtonFormField<ZoneTheme>(
                                value: _zone,
                                decoration: const InputDecoration(labelText: 'Zone'),
                                items: ZoneTheme.values
                                    .map((z) => DropdownMenuItem(
                                        value: z, child: Text(z.name)))
                                    .toList(),
                                onChanged: (v) => setState(() => _zone = v!),
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                        SwitchListTile(
                          title: const Text('Password-Lock'),
                          subtitle:
                              Text(_lockToggle ? 'Locked' : 'Unlocked'),
                          value: _lockToggle,
                          onChanged: _onLockToggle,
                        ),
                      ],
                    ),
                  ),
                ),

                // Tracker tabs
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'Goals'),
                    Tab(text: 'Tasks'),
                    Tab(text: 'Events'),
                    Tab(text: 'Series'),
                  ],
                ),

                // Tracker lists
                SizedBox(
                  height: 250,
                  child: TabBarView(
                    controller: _tabController,
                    children: TrackerType.values
                        .map((type) => _buildTrackerList(type))
                        .toList(),
                  ),
                ),

                // Add button that matches the current tab
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: ElevatedButton.icon(
                    icon: _iconForType(
                        TrackerType.values[_tabController.index]),
                    label: Text(
                        'Add ${TrackerType.values[_tabController.index].name}'),
                    onPressed: () => _addTracker(
                        TrackerType.values[_tabController.index]),
                  ),
                ),
              ],
            ),
    );
  }
}

/// Dialog to quickly create a new tracker of a given type.
class _QuickTrackerDialog extends StatefulWidget {
  final TrackerType type;
  const _QuickTrackerDialog({required this.type});

  @override
  _QuickTrackerDialogState createState() => _QuickTrackerDialogState();
}

class _QuickTrackerDialogState extends State<_QuickTrackerDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleCtl, _progressCtl, _frequencyCtl;
  DateTime? _start;

  @override
  void initState() {
    super.initState();
    _titleCtl = TextEditingController();
    _progressCtl = TextEditingController();
    _frequencyCtl = TextEditingController();
  }

  @override
  void dispose() {
    _titleCtl.dispose();
    _progressCtl.dispose();
    _frequencyCtl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) setState(() => _start = picked);
  }

  @override
  Widget build(BuildContext context) {
    final type = widget.type;
    final typeName = type.name[0].toUpperCase() + type.name.substring(1);
    return AlertDialog(
      title: Text('New $typeName'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextFormField(
              controller: _titleCtl,
              decoration: const InputDecoration(labelText: 'Title'),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            if (type == TrackerType.goal) ...[
              const SizedBox(height: 8),
              TextFormField(
                controller: _progressCtl,
                decoration: const InputDecoration(labelText: 'Progress (0–1)'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
            ],
            if (type == TrackerType.task) ...[
              const SizedBox(height: 8),
              TextFormField(
                controller: _frequencyCtl,
                decoration: const InputDecoration(labelText: 'Frequency'),
              ),
            ],
            if (type == TrackerType.event) ...[
              const SizedBox(height: 8),
              Row(children: [
                Expanded(
                  child: Text(_start == null
                      ? 'No date chosen'
                      : _start!.toLocal().toString().split(' ')[0]),
                ),
                TextButton(onPressed: _pickDate, child: const Text('Pick Date')),
              ]),
            ],
          ]),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            final id = generateId();
            final tracker = Tracker(
              id: id,
              type: widget.type,
              title: _titleCtl.text,
              progress: widget.type == TrackerType.goal
                  ? double.tryParse(_progressCtl.text)
                  : null,
              frequency:
                  widget.type == TrackerType.task ? _frequencyCtl.text : null,
              start: widget.type == TrackerType.event ? _start : null,
            );
            Navigator.pop(context, tracker);
          },
          child: const Text('Create'),
        ),
      ],
    );
  }
}
