import 'package:flutter/material.dart';
import '../models/tracker.dart';
import '../models/tracker_type.dart';
import '../services/tracker_service.dart';
import '../utils/id_generator.dart';
import '../widgets/main_menu_drawer.dart';

/// Page for creating or editing a [Tracker].
class ForgeEditorPage extends StatefulWidget {
  /// Argument passed via Navigator. Can be [Tracker], [TrackerType] or tracker id [String].
  final dynamic argument;
  const ForgeEditorPage({super.key, this.argument});

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
      try {
        _tracker = TrackerService.instance.all.firstWhere((t) => t.id == arg);
        _type = _tracker!.type;
      } catch (_) {}
    }
    _titleCtl = TextEditingController(text: _tracker?.title ?? '');
    _progressCtl = TextEditingController(
        text: _tracker?.progress != null ? _tracker!.progress.toString() : '');
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
    if (date != null) {
      setState(() => _start = date);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _type == null) return;
    final tracker =
        _tracker ?? Tracker(id: generateId(), type: _type!, title: '');
    tracker
      ..title = _titleCtl.text
      ..type = _type!;
    if (_type == TrackerType.goal) {
      tracker.progress = double.tryParse(_progressCtl.text) ?? 0;
    } else if (_type == TrackerType.task) {
      tracker.frequency = _frequencyCtl.text;
    } else if (_type == TrackerType.event) {
      tracker.start = _start;
    }
    await TrackerService.instance.save(tracker);
    Navigator.pop(context, tracker);
  }

  Widget _buildTypeFields() {
    switch (_type) {
      case TrackerType.goal:
        return TextFormField(
          controller: _progressCtl,
          decoration: const InputDecoration(labelText: 'Progress (0-1)'),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        );
      case TrackerType.task:
        return TextFormField(
          controller: _frequencyCtl,
          decoration: const InputDecoration(labelText: 'Frequency'),
        );
      case TrackerType.event:
        return Row(
          children: [
            Expanded(
              child: Text(
                _start != null
                    ? _start!.toLocal().toString()
                    : 'No date selected',
              ),
            ),
            TextButton(
              onPressed: _pickDate,
              child: const Text('Select Date'),
            ),
          ],
        );
      case TrackerType.series:
      case null:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _tracker == null ? 'New Tracker' : 'Edit Tracker';
    return Scaffold(
      drawer: const MainMenuDrawer(),
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _save),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              DropdownButtonFormField<TrackerType>(
                value: _type,
                decoration: const InputDecoration(labelText: 'Type'),
                items: TrackerType.values
                    .map((t) => DropdownMenuItem(
                          value: t,
                          child: Text(t.name),
                        ))
                    .toList(),
                onChanged: (t) => setState(() => _type = t),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _titleCtl,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (val) =>
                    (val == null || val.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              _buildTypeFields(),
            ],
          ),
        ),
      ),
    );
  }
}
