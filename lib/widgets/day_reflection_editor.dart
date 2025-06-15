// lib/widgets/day_reflection_editor.dart

import 'package:flutter/material.dart';
import '../models/day_reflection.dart';

class DayReflectionEditor extends StatefulWidget {
  /// If non-null, we’re editing an existing reflection.
  final DayReflection? existing;

  /// Called with the new summary text when the user taps “Save”.
  final Future<void> Function(String) onSave;

  const DayReflectionEditor({
    super.key,
    this.existing,
    required this.onSave,
  });

  @override
  _DayReflectionEditorState createState() => _DayReflectionEditorState();
}

class _DayReflectionEditorState extends State<DayReflectionEditor> {
  late TextEditingController _ctl;

  @override
  void initState() {
    super.initState();
    // Initialize the controller with the existing summary, if any.
    _ctl = TextEditingController(text: widget.existing?.summary ?? '');
  }

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.existing == null ? 'New Reflection' : 'Edit Reflection',
      ),
      content: TextField(
        controller: _ctl,
        maxLines: null,
        decoration: const InputDecoration(
          labelText: 'Today’s Reflection',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(), // cancel
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            final text = _ctl.text.trim();
            if (text.isNotEmpty) {
              await widget.onSave(text);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
