// File: lib/widgets/multi_pane_editor.dart

import 'package:flutter/material.dart';
import '../models/block.dart';
import 'block_renderer.dart';

/// A simple multi-pane editor that shows a list of blocks on the left
/// and the rendered content on the right.
class MultiPaneEditor extends StatefulWidget {
  final List<Block> blocks;

  const MultiPaneEditor({super.key, required this.blocks});

  @override
  State<MultiPaneEditor> createState() => _MultiPaneEditorState();
}

class _MultiPaneEditorState extends State<MultiPaneEditor> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 200,
          child: ListView.builder(
            itemCount: widget.blocks.length,
            itemBuilder: (context, i) => ListTile(
              title: Text(widget.blocks[i].id),
              selected: i == _selected,
              onTap: () => setState(() => _selected = i),
            ),
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: BlockRenderer(block: widget.blocks[_selected]),
          ),
        ),
      ],
    );
  }
}
