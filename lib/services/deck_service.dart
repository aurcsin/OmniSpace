// File: lib/services/deck_service.dart

import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../models/deck.dart';
import '../models/spirit.dart';
import '../models/zone_theme.dart';
import 'spirit_service.dart';

class DeckService extends ChangeNotifier {
  DeckService._internal();
  static final DeckService instance = DeckService._internal();

  static const String _boxName = 'decks';
  late final Box<Deck> _box;

  /// Initialize Hive box, seed with each realm’s Master Spirit if empty.
  Future<void> init() async {
    if (!Hive.isAdapterRegistered(DeckAdapter().typeId)) {
      Hive.registerAdapter(DeckAdapter());
    }
    _box = await Hive.openBox<Deck>(_boxName);

    if (_box.isEmpty) {
      // Create a new deck seeded with one Master Spirit per realm
      final deck = Deck(spiritIds: ZoneTheme.values
          .map((realm) => SpiritService.instance.getPrimary(realm)!.id)
          .toList());
      await _box.add(deck);
    }
    notifyListeners();
  }

  Deck get deck => _box.values.first;

  /// All spirits in the user’s deck.
  List<Spirit> get cards => deck.spiritIds
      .map((id) => SpiritService.instance.all.firstWhere((s) => s.id == id))
      .toList();

  /// Add a spirit to the deck (if not already present).
  Future<void> draw(Spirit spirit) async {
    if (!deck.spiritIds.contains(spirit.id)) {
      deck.spiritIds.add(spirit.id);
      await deck.save();
      notifyListeners();
    }
  }

  /// Remove a spirit from the deck.
  Future<void> remove(Spirit spirit) async {
    if (deck.spiritIds.remove(spirit.id)) {
      await deck.save();
      notifyListeners();
    }
  }

  /// Clear *all* spirits from the deck, then re–seed Masters.
  Future<void> reset() async {
    deck.spiritIds.clear();
    // reseed with masters
    deck.spiritIds.addAll(
      ZoneTheme.values.map((realm) => SpiritService.instance.getPrimary(realm)!.id),
    );
    await deck.save();
    notifyListeners();
  }

  /// Draw a random new spirit from the pool of collectable spirits
  /// that aren’t already in your deck.
  Future<Spirit?> drawRandomCollectible() async {
    final allCollectible = SpiritService.instance.all
        .where((s) => s.isCollectible && !deck.spiritIds.contains(s.id))
        .toList();
    if (allCollectible.isEmpty) return null;
    final rand = Random();
    final pick = allCollectible[rand.nextInt(allCollectible.length)];
    await draw(pick);
    return pick;
  }

  /// Draw a random spirit from a specific [realm] (NPC or collectible).
  Future<Spirit?> drawFromRealm(ZoneTheme realm) async {
    final pool = SpiritService.instance.forRealm(realm)
        .where((s) => !deck.spiritIds.contains(s.id))
        .toList();
    if (pool.isEmpty) return null;
    final rand = Random();
    final pick = pool[rand.nextInt(pool.length)];
    await draw(pick);
    return pick;
  }
}
