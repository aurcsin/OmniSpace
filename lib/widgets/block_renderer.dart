// File: lib/widgets/block_renderer.dart

import 'package:flutter/material.dart';
import '../models/block.dart';

/// Renders a [Block] based on its type.
class BlockRenderer extends StatelessWidget {
  final Block block;

  const BlockRenderer({super.key, required this.block});

  @override
  Widget build(BuildContext context) {
    switch (block.type) {
      case 'text':
        return Text(block.data);
      case 'image':
        return Image.network(block.data, fit: BoxFit.cover);
      case 'checklist':
        return CheckboxListTile(
          value: block.data == 'true',
          onChanged: (_) {},
          title: Text(block.id),
        );
      default:
        return Text('Unsupported block: ${block.type}');
    }
  }
}
