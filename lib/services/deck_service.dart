import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../models/deck.dart';
import '../models/spirit.dart';
import '../models/zone_theme.dart';
import 'spirit_service.dart';

class DeckService extends ChangeNotifier {
  DeckService._internal();
  static final DeckService instance = DeckService._internal();

  static const _boxName = 'decks';
  late final Box<Deck> _box;
  late Deck deck;

  /// Call once at startup.
  Future<void> init() async {
    if (!Hive.isAdapterRegistered(DeckAdapter().typeId)) {
      Hive.registerAdapter(DeckAdapter());
    }
    // Open only the decks box — no reset or cleaning:
    _box = await Hive.openBox<Deck>(_boxName);

    // If first run, create a deck—but skip any box.clear() or migrations:
    if (_box.isEmpty) {
      final d = Deck(id: 'user_deck', title: 'My Deck');
      await _box.put(d.id, d);
      deck = d;
    } else {
      deck = _box.get('user_deck')!;
    }

    notifyListeners();
  }

  List<Spirit> get cards => SpiritService.instance.all
    .where((s) => deck.spiritIds.contains(s.id))
    .toList();

  Future<Spirit?> draw(Spirit s) async {
    if (!deck.spiritIds.contains(s.id)) {
      deck.spiritIds.add(s.id);
      await _box.put(deck.id, deck);
      notifyListeners();
      return s;
    }
    return null;
  }

  Future<Spirit?> drawFromRealm(ZoneTheme realm) async {
    final pool = SpiritService.instance.getByRealm(realm)
      .where((s) => !deck.spiritIds.contains(s.id))
      .toList();
    if (pool.isEmpty) return null;
    deck.spiritIds.add(pool.first.id);
    await _box.put(deck.id, deck);
    notifyListeners();
    return pool.first;
  }

  Future<void> reset() async {
    deck.spiritIds.clear();
    await _box.put(deck.id, deck);
    notifyListeners();
  }

  Future<void> remove(Spirit s) async {
    if (deck.spiritIds.remove(s.id)) {
      await _box.put(deck.id, deck);
      notifyListeners();
    }
  }
}
