// File: lib/services/spirit_service.dart

import 'package:hive/hive.dart';
import '../models/spirit.dart';
import '../models/zone_theme.dart';

class SpiritService {
  SpiritService._();
  static final SpiritService instance = SpiritService._();

  static const _boxName = 'spirits';
  late final Box<Spirit> _box;

  /// Call once at app startup (after adapters registered).
  Future<void> init() async {
    // Ensure adapters are registered exactly once:
    if (!Hive.isAdapterRegistered(SpiritAdapter().typeId)) {
      Hive.registerAdapter(SpiritAdapter());
    }
    if (!Hive.isAdapterRegistered(ZoneThemeAdapter().typeId)) {
      Hive.registerAdapter(ZoneThemeAdapter());
    }

    // Open the dedicated spirits box only—do NOT seed or clear anything here
    _box = await Hive.openBox<Spirit>(_boxName);

    // 🚫 Temporarily disabled automatic seeding to avoid cross-typing errors
    // if (_box.isEmpty) {
    //   await _seedSpirits();
    // }
  }

  /*
/// When you’re ready to restore the “one-time seeding” behavior, re-enable this method call
/// and uncomment this entire block:
  Future<void> _seedSpirits() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    var counter = 0;

    for (final realm in ZoneTheme.values) {
      final master = Spirit(
        id: '$now-${realm.index}-master',
        name: '${_capitalize(realm.name)} Guardian',
        mythos: 'A potent spirit embodying the essence of ${realm.name}.',
        purpose: 'Guides experienced travelers through the ${realm.name} realm.',
        useInApp: 'Appears on the ${_capitalize(realm.name)} page to offer wisdom.',
        realm: realm,
        isPrimary: true,
        isNPC: false,
        isCollectible: false,
        archetype: 'Guardian',
        xpValue: 100,
      );
      await _box.put(master.id, master);

      counter++;
      final sprite = Spirit(
        id: '$now-${realm.index}-sprite-$counter',
        name: 'Young ${_capitalize(realm.name)} Sprite',
        mythos: 'A fledgling spirit attuned to the playful side of ${realm.name}.',
        purpose: 'Helps newcomers learn the basics of the ${realm.name} realm.',
        useInApp: 'Reserved for your beginner deck on the ${_capitalize(realm.name)} page.',
        realm: realm,
        isPrimary: false,
        isNPC: false,
        isCollectible: true,
        archetype: 'Sprite',
        xpValue: 10,
      );
      await _box.put(sprite.id, sprite);
    }
  }

  String _capitalize(String s) =>
      s.isEmpty ? '' : s[0].toUpperCase() + s.substring(1);
  */

  /// Returns all spirits in the box.
  List<Spirit> get all => _box.values.toList();

  /// Only the primary (master) spirits.
  List<Spirit> getPrimaries() => all.where((s) => s.isPrimary).toList();

  /// Only collectible spirits.
  List<Spirit> getCollectibles() => all.where((s) => s.isCollectible).toList();

  /// All spirits in a specific realm.
  List<Spirit> getByRealm(ZoneTheme realm) =>
      all.where((s) => s.realm == realm).toList();

  /// Lookup by ID.
  Spirit? getById(String id) => _box.get(id);
}
