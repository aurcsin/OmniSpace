// File: lib/models/graph.dart

/// Node within a knowledge graph.
class GraphNode {
  final String id;
  final String label;
  double x;
  double y;

  GraphNode({
    required this.id,
    required this.label,
    this.x = 0,
    this.y = 0,
  });

  factory GraphNode.fromJson(Map<String, dynamic> json) => GraphNode(
        id: json['id'] as String,
        label: json['label'] as String,
        x: (json['x'] as num?)?.toDouble() ?? 0,
        y: (json['y'] as num?)?.toDouble() ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'x': x,
        'y': y,
      };
}

/// Directed edge between nodes.
class GraphEdge {
  final String fromId;
  final String toId;
  GraphEdge({required this.fromId, required this.toId});

  factory GraphEdge.fromJson(Map<String, dynamic> json) =>
      GraphEdge(fromId: json['fromId'] as String, toId: json['toId'] as String);

  Map<String, dynamic> toJson() => {'fromId': fromId, 'toId': toId};
}

/// Simple graph structure containing nodes and edges.
class Graph {
  final List<GraphNode> nodes;
  final List<GraphEdge> edges;

  Graph({this.nodes = const [], this.edges = const []});

  factory Graph.fromJson(Map<String, dynamic> json) => Graph(
        nodes: (json['nodes'] as List<dynamic>? ?? [])
            .map((n) => GraphNode.fromJson(n as Map<String, dynamic>))
            .toList(),
        edges: (json['edges'] as List<dynamic>? ?? [])
            .map((e) => GraphEdge.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'nodes': nodes.map((n) => n.toJson()).toList(),
        'edges': edges.map((e) => e.toJson()).toList(),
      };
}
