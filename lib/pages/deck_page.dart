// lib/services/deck_service.dart

import 'package:hive/hive.dart';
import 'package:omnispace/models/deck.dart';
import 'package:omnispace/models/spirit.dart';
import 'package:omnispace/models/zone_theme.dart';
import 'package:omnispace/services/spirit_service.dart';

class DeckService {
  DeckService._();
  static final instance = DeckService._();

  static const _boxName = 'deck';
  static const _stateKey = 'current';

  late Box<Deck> _box;
  Deck? _state;
  final List<Spirit> _deck = [];

  /// Call once at app startup to open Hive box and restore deck state.
  Future<void> init() async {
    _box = await Hive.openBox<Deck>(_boxName);
    _state = _box.get(_stateKey);
    if (_state != null) {
      _deck
        ..clear()
        ..addAll(
          _state!.spiritIds
              .map((id) => SpiritService.instance.getById(id))
              .whereType<Spirit>(),
        );
    }
  }

  /// The current deck of spirits.
  List<Spirit> get deck => List.unmodifiable(_deck);

  /// Alias for UI pages that refer to cards.
  List<Spirit> get cards => deck;

  /// Draw a specific spirit into the deck, if not already present.
  Future<Spirit?> draw(Spirit s) async {
    if (_deck.any((existing) => existing.id == s.id)) return null;
    _deck.add(s);
    await _saveState();
    return s;
  }

  /// Draw a random new collectible spirit from the given realm.
  Future<Spirit?> drawFromRealm(ZoneTheme realm) async {
    final available = SpiritService.instance
        .getByRealm(realm)
        .where((s) => s.isCollectible && !_deck.any((d) => d.id == s.id))
        .toList();
    if (available.isEmpty) return null;
    available.shuffle();
    final pick = available.first;
    _deck.add(pick);
    await _saveState();
    return pick;
  }

  /// Draw a random new collectible spirit from any realm.
  Future<Spirit?> drawRandomCollectible() async {
    final allCollectibles = SpiritService.instance.getCollectibles();
    final available = allCollectibles
        .where((s) => !_deck.any((d) => d.id == s.id))
        .toList();
    if (available.isEmpty) return null;
    available.shuffle();
    final pick = available.first;
    _deck.add(pick);
    await _saveState();
    return pick;
  }

  /// Remove a spirit from the deck.
  Future<void> remove(Spirit s) async {
    _deck.removeWhere((d) => d.id == s.id);
    await _saveState();
  }

  /// Reset the deck to empty.
  Future<void> reset() async {
    _deck.clear();
    await _saveState();
  }

  Future<void> _saveState() async {
    final ids = _deck.map((s) => s.id).toList();
    final newState = Deck(
      id: _stateKey,
      title: 'My Deck',
      spiritIds: ids,
    );
    await _box.put(_stateKey, newState);
    _state = newState;
  }
}
