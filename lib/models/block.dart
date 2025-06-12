// File: lib/models/block.dart

/// Represents a reusable content block within an entry.
class Block {
  /// Unique id for this block.
  final String id;

  /// Type of block e.g. text, image, audio, checklist.
  final String type;

  /// Raw data payload for the block. Can be markdown or path to media.
  final String data;

  /// Child blocks for nested structures.
  final List<Block> children;

  Block({
    required this.id,
    required this.type,
    required this.data,
    this.children = const [],
  });

  /// Convert a Block from JSON.
  factory Block.fromJson(Map<String, dynamic> json) => Block(
        id: json['id'] as String,
        type: json['type'] as String,
        data: json['data'] as String? ?? '',
        children: (json['children'] as List<dynamic>? ?? [])
            .map((e) => Block.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  /// Convert Block to JSON.
  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'data': data,
        'children': children.map((c) => c.toJson()).toList(),
      };
}
