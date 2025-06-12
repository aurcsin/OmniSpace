// File: lib/models/deck.dart

import 'block.dart';

/// Collection of reusable blocks or cards that can be inserted into notes.
class Deck {
  /// Unique id for the deck.
  final String id;

  /// Display title of the deck.
  final String title;

  /// Blocks contained within this deck.
  final List<Block> blocks;

  Deck({required this.id, required this.title, this.blocks = const []});

  factory Deck.fromJson(Map<String, dynamic> json) => Deck(
        id: json['id'] as String,
        title: json['title'] as String,
        blocks: (json['blocks'] as List<dynamic>? ?? [])
            .map((e) => Block.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'blocks': blocks.map((b) => b.toJson()).toList(),
      };
}
