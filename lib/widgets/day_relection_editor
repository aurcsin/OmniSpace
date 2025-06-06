import 'package:flutter/material.dart';
import 'package:omnispace/models/day_reflection.dart';

class DayReflectionEditor extends StatefulWidget {
  final DayReflection? existing;
  final Function(String summary) onSave;

  const DayReflectionEditor({
    Key? key,
    required this.onSave,
    this.existing,
  }) : super(key: key);

  @override
  _DayReflectionEditorState createState() => _DayReflectionEditorState();
}

class _DayReflectionEditorState extends State<DayReflectionEditor> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        TextEditingController(text: widget.existing?.summary ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existing == null
          ? 'Add Day Reflection'
          : 'Edit Day Reflection'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(
          hintText: 'Write your thoughts about this day...',
        ),
        maxLines: 6,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onSave(_controller.text.trim());
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
