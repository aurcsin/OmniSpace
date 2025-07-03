// File: lib/pages/forge_editor_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/tracker.dart';
import '../models/tracker_type.dart';
import '../services/tracker_service.dart';
import '../utils/id_generator.dart';
import '../widgets/main_menu_drawer.dart';

/// Page for creating or editing a [Tracker].
/// Accepts either a Tracker instance, a TrackerType, or a String id.
class ForgeEditorPage extends StatefulWidget {
  final dynamic argument;
  const ForgeEditorPage({Key? key, this.argument}) : super(key: key);

  @override
  State<ForgeEditorPage> createState() => _ForgeEditorPageState();
}

class _ForgeEditorPageState extends State<ForgeEditorPage> {
  final _formKey = GlobalKey<FormState>();
  Tracker? _tracker;
  TrackerType? _type;

  late TextEditingController _titleCtl;
  late TextEditingController _progressCtl;
  late TextEditingController _frequencyCtl;
  DateTime? _start;

  @override
  void initState() {
    super.initState();

    final arg = widget.argument;
    if (arg is Tracker) {
      _tracker = arg;
      _type = arg.type;
    } else if (arg is TrackerType) {
      _type = arg;
    } else if (arg is String) {
      // Use getById instead of byId
      _tracker = TrackerService.instance.getById(arg);
      _type = _tracker?.type;
    }

    _titleCtl = TextEditingController(text: _tracker?.title ?? '');
    _progressCtl = TextEditingController(
      text: _tracker?.progress?.toString() ?? '',
    );
    _frequencyCtl = TextEditingController(text: _tracker?.frequency ?? '');
    _start = _tracker?.start;
  }

  @override
  void dispose() {
    _titleCtl.dispose();
    _progressCtl.dispose();
    _frequencyCtl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _start ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null) setState(() => _start = date);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _type == null) return;

    final t = _tracker ??
        Tracker(id: generateId(), type: _type!, title: '');
    t
      ..title = _titleCtl.text.trim()
      ..type = _type!;

    if (_type == TrackerType.goal) {
      t.progress = double.tryParse(_progressCtl.text) ?? 0;
    } else if (_type == TrackerType.routine) {
      t.frequency = _frequencyCtl.text.trim();
    } else if (_type == TrackerType.event) {
      t.start = _start;
    }

    await TrackerService.instance.save(t);
    Navigator.of(context).pop(t);
  }

  Widget _buildTypeFields() {
    switch (_type) {
      case TrackerType.goal:
        return TextFormField(
          controller: _progressCtl,
          decoration: const InputDecoration(labelText: 'Progress (0–1)'),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: (v) {
            final x = double.tryParse(v ?? '');
            if (x == null || x < 0 || x > 1) {
              return 'Enter a value between 0 and 1';
            }
            return null;
          },
        );

      case TrackerType.routine:
        return TextFormField(
          controller: _frequencyCtl,
          decoration: const InputDecoration(labelText: 'Recurrence (e.g. daily)'),
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Required' : null,
        );

      case TrackerType.event:
        return Row(
          children: [
            Expanded(
              child: Text(
                _start != null
                    ? 'On: ${DateFormat.yMMMd().format(_start!)}'
                    : 'No date selected',
              ),
            ),
            TextButton(onPressed: _pickDate, child: const Text('Pick Date')),
          ],
        );

      case TrackerType.series:
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isNew = _tracker == null;
    return Scaffold(
      drawer: const MainMenuDrawer(),
      appBar: AppBar(
        title: Text(isNew ? 'New Tracker' : 'Edit Tracker'),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _save),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<TrackerType>(
                value: _type,
                decoration: const InputDecoration(labelText: 'Type'),
                items: TrackerType.values.map((t) {
                  return DropdownMenuItem(
                    value: t,
                    child: Text(t.name[0].toUpperCase() + t.name.substring(1)),
                  );
                }).toList(),
                onChanged: (t) => setState(() => _type = t),
                validator: (v) => v == null ? 'Please select a type' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleCtl,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Enter a title' : null,
              ),
              const SizedBox(height: 16),
              _buildTypeFields(),
            ],
          ),
        ),
      ),
    );
  }
}
