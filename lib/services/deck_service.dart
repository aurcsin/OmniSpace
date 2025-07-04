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
  final List<Spirit> _deck = [];

  /// Must be called once at app startup.
  Future<void> init() async {
    _box = await Hive.openBox<Deck>(_boxName);
    final state = _box.get(_stateKey);
    if (state != null) {
      _deck
        ..clear()
        ..addAll(
          state.spiritIds
            .map((id) => SpiritService.instance.getById(id))
            .whereType<Spirit>(),
        );
    }
  }

  /// The current deck of spirits. Throws if init() wasn’t called.
  List<Spirit> get deck {
    if (!_box.isOpen) {
      throw StateError('DeckService.init() must be called before reading deck');
    }
    return List.unmodifiable(_deck);
  }

  /// Alias for UI code that expects `cards`.
  List<Spirit> get cards => deck;

  Future<Spirit?> draw(Spirit s) async {
    if (_deck.any((e) => e.id == s.id)) return null;
    _deck.add(s);
    await _saveState();
    return s;
  }

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

  Future<Spirit?> drawRandomCollectible() async {
    final all = SpiritService.instance.getCollectibles();
    final available = all.where((s) => !_deck.any((d) => d.id == s.id)).toList();
    if (available.isEmpty) return null;
    available.shuffle();
    final pick = available.first;
    _deck.add(pick);
    await _saveState();
    return pick;
  }

  Future<void> remove(Spirit s) async {
    _deck.removeWhere((d) => d.id == s.id);
    await _saveState();
  }

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
  }
}
