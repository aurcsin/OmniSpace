// File: lib/pages/multi_pane_editor_page.dart

import 'package:flutter/material.dart';
import '../models/block.dart';
import '../widgets/multi_pane_editor.dart';

/// Page demonstrating the [MultiPaneEditor].
class MultiPaneEditorPage extends StatelessWidget {
  const MultiPaneEditorPage({super.key});

  @override
  Widget build(BuildContext context) {
    final sampleBlocks = [
      Block(id: 'Intro', type: 'text', data: 'Welcome to OmniSpace'),
      Block(id: 'Mood', type: 'text', data: 'Feeling great!'),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Multi-Pane Editor')),
      body: MultiPaneEditor(blocks: sampleBlocks),
    );
  }
}
