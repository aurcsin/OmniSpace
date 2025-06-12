// File: lib/widgets/graph_canvas.dart

import 'package:flutter/material.dart';
import '../models/graph.dart';

/// Very basic graph canvas that lays out nodes in a stack.
class GraphCanvas extends StatelessWidget {
  final Graph graph;

  const GraphCanvas({super.key, required this.graph});

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      child: Stack(
        children: [
          for (final node in graph.nodes)
            Positioned(
              left: node.x,
              top: node.y,
              child: _DraggableNode(node: node),
            ),
        ],
      ),
    );
  }
}

class _DraggableNode extends StatefulWidget {
  final GraphNode node;
  const _DraggableNode({required this.node});

  @override
  State<_DraggableNode> createState() => _DraggableNodeState();
}

class _DraggableNodeState extends State<_DraggableNode> {
  @override
  Widget build(BuildContext context) {
    return Draggable<GraphNode>(
      feedback: _buildNode(),
      childWhenDragging: const SizedBox.shrink(),
      onDraggableCanceled: (_, offset) => setState(() {
        widget.node
          ..x = offset.dx
          ..y = offset.dy;
      }),
      child: _buildNode(),
    );
  }

  Widget _buildNode() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.blueAccent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(widget.node.label,
          style: const TextStyle(color: Colors.white)),
    );
  }
}
