// File: lib/models/deck.dart

import 'package:hive/hive.dart';

part 'deck.g.dart';

/// A user’s personal Spirit Deck, storing references to collected spirits.
@HiveType(typeId: 51)
class Deck extends HiveObject {
  /// IDs of the Spirits in this deck.
  @HiveField(0)
  List<String> spiritIds;

  Deck({List<String>? spiritIds}) : spiritIds = spiritIds ?? [];
}
