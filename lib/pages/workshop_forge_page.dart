import 'package:flutter/material.dart';
import '../models/project.dart';
import '../services/project_service.dart';
import '../services/omni_note_service.dart';
import '../services/tracker_service.dart';
import '../widgets/main_menu_drawer.dart';
import '../utils/id_generator.dart';

class WorkshopForgePage extends StatefulWidget {
  final List<String> preselectedNotes;
  final List<String> preselectedTrackers;

  const WorkshopForgePage({
    super.key,
    this.preselectedNotes = const [],
    this.preselectedTrackers = const [],
  });

  @override
  State<WorkshopForgePage> createState() => _WorkshopForgePageState();
}

class _WorkshopForgePageState extends State<WorkshopForgePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleCtl;
  late Set<String> _noteIds;
  late Set<String> _trackerIds;

  @override
  void initState() {
    super.initState();
    _titleCtl = TextEditingController();
    _noteIds = {...widget.preselectedNotes};
    _trackerIds = {...widget.preselectedTrackers};
  }

  @override
  void dispose() {
    _titleCtl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final p = Project(id: generateId());
    p
      ..title = _titleCtl.text
      ..noteIds = _noteIds.toList()
      ..trackerIds = _trackerIds.toList();
    await ProjectService.instance.save(p);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final notes = OmniNoteService.instance.notes;
    final trackers = TrackerService.instance.all;
    return Scaffold(
      drawer: const MainMenuDrawer(),
      appBar: AppBar(
        title: const Text('Create Project'),
        actions: [IconButton(icon: const Icon(Icons.save), onPressed: _save)],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleCtl,
              decoration: const InputDecoration(labelText: 'Project Title'),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            const Text('Select Notes', style: TextStyle(fontWeight: FontWeight.bold)),
            ...notes.map((n) => CheckboxListTile(
                  title: Text(n.title),
                  value: _noteIds.contains(n.id),
                  onChanged: (v) {
                    setState(() {
                      if (v == true) {
                        _noteIds.add(n.id);
                      } else {
                        _noteIds.remove(n.id);
                      }
                    });
                  },
                )),
            const SizedBox(height: 16),
            const Text('Select Trackers', style: TextStyle(fontWeight: FontWeight.bold)),
            ...trackers.map((t) => CheckboxListTile(
                  title: Text(t.title),
                  value: _trackerIds.contains(t.id),
                  onChanged: (v) {
                    setState(() {
                      if (v == true) {
                        _trackerIds.add(t.id);
                      } else {
                        _trackerIds.remove(t.id);
                      }
                    });
                  },
                )),
          ],
        ),
      ),
    );
  }
}
