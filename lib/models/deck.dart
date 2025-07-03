import 'package:hive/hive.dart';

part 'deck.g.dart';

/// Your personal collection of spirit IDs.
@HiveType(typeId: 2)
class Deck extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  /// The collected spirit IDs.
  @HiveField(2)
  List<String> spiritIds;

  Deck({
    required this.id,
    required this.title,
    this.spiritIds = const [],
  });
}
