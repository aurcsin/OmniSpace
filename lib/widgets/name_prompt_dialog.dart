// lib/widgets/name_prompt_dialog.dart

import 'package:flutter/material.dart';

/// Dialog to prompt for a new item name.
class NamePromptDialog extends StatelessWidget {
  final String label;
  const NamePromptDialog({Key? key, required this.label}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ctl = TextEditingController();
    return AlertDialog(
      title: Text('New ${label[0].toUpperCase()}${label.substring(1)}'),
      content: TextField(
        controller: ctl,
        decoration: InputDecoration(hintText: '$label title'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, ctl.text),
          child: const Text('Create'),
        ),
      ],
    );
  }
}
