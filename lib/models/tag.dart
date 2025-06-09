// File: lib/models/tag.dart

import 'package:hive/hive.dart';

part 'tag.g.dart';

/// Represents a label that can be attached to notes.
@HiveType(typeId: 13)
class Tag extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String label;

  @HiveField(2)
  int colorValue;

  Tag({
    required this.id,
    this.label = '',
    this.colorValue = 0xFFFFFFFF,
  });

  /// Convert this tag to a JSON map.
  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'colorValue': colorValue,
      };

  /// Create a Tag from a JSON map.
  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      id: json['id'] as String,
      label: json['label'] as String? ?? '',
      colorValue: json['colorValue'] as int? ?? 0xFFFFFFFF,
    );
  }
}
