// File: lib/widgets/help_button.dart

import 'package:flutter/material.dart';

/// A small “?” icon that shows a page-specific help dialog.
class HelpButton extends StatelessWidget {
  /// The dialog title (e.g. “Journal Help”).
  final String helpTitle;

  /// The dialog body text.
  final String helpText;

  const HelpButton({
    Key? key,
    required this.helpTitle,
    required this.helpText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.help_outline),
      tooltip: 'Help',
      onPressed: () {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(helpTitle),
            content: SingleChildScrollView(child: Text(helpText)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      },
    );
  }
}
