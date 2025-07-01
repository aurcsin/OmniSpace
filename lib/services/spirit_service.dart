// File: lib/services/spirit_service.dart

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import 'package:omnispace/models/spirit.dart';
import 'package:omnispace/models/zone_theme.dart';

/// Manages all Spirits in the OmniSpace world.
class SpiritService extends ChangeNotifier {
  SpiritService._internal();
  static final SpiritService instance = SpiritService._internal();

  static const String _boxName = 'spirits';
  late final Box<Spirit> _box;

  /// Initialize Hive box and seed defaults if empty.
  Future<void> init() async {
    if (!Hive.isAdapterRegistered(SpiritAdapter().typeId)) {
      Hive.registerAdapter(SpiritAdapter());
    }
    _box = await Hive.openBox<Spirit>(_boxName);

    if (_box.isEmpty) {
      await _seedDefaults();
    }
    notifyListeners();
  }

  /// All spirits.
  List<Spirit> get all => _box.values.toList();

  /// All spirits belonging to [realm].
  List<Spirit> forRealm(ZoneTheme realm) =>
      all.where((s) => s.realm == realm).toList();

  /// The primary (master) spirit of [realm], or the first if none marked primary.
  Spirit? getPrimary(ZoneTheme realm) {
    final spirits = forRealm(realm);
    if (spirits.isEmpty) return null;
    return spirits.firstWhere((s) => s.isPrimary, orElse: () => spirits.first);
  }

  /// Seed each realm with a master spirit, one collectable, and optional heralds.
  Future<void> _seedDefaults() async {
    // Air realm
    await _box.addAll([
      Spirit(
        id: 'air_master',
        name: 'Zephyr, The Whispering Wind',
        description: 'Guardian of the Sky, offering lofty perspective.',
        realm: ZoneTheme.Air,
        isPrimary: true,
        isNPC: true,
      ),
      Spirit(
        id: 'air_herald1',
        name: 'Gale Herald',
        description: 'A messenger spirit bringing fresh ideas.',
        realm: ZoneTheme.Air,
        isNPC: true,
      ),
      Spirit(
        id: 'cloudling',
        name: 'Cloudling',
        description: 'A fluffy curiosity drifting on breezes.',
        realm: ZoneTheme.Air,
        isCollectible: true,
      ),
    ]);

    // Earth realm
    await _box.addAll([
      Spirit(
        id: 'earth_master',
        name: 'Gaia, The Sustaining Mother',
        description: 'Guardian of Earth, nurturing growth.',
        realm: ZoneTheme.Earth,
        isPrimary: true,
        isNPC: true,
      ),
      Spirit(
        id: 'sproutling',
        name: 'Sproutling',
        description: 'A tiny seedling spirit eager to grow.',
        realm: ZoneTheme.Earth,
        isCollectible: true,
      ),
    ]);

    // Fire realm
    await _box.addAll([
      Spirit(
        id: 'fire_master',
        name: 'Emberon, The Eternal Flame',
        description: 'Guardian of Fire, igniting passion.',
        realm: ZoneTheme.Fire,
        isPrimary: true,
        isNPC: true,
      ),
      Spirit(
        id: 'sparklet',
        name: 'Sparklet',
        description: 'A fleeting ember, full of energy.',
        realm: ZoneTheme.Fire,
        isCollectible: true,
      ),
    ]);

    // Water realm
    await _box.addAll([
      Spirit(
        id: 'water_master',
        name: 'Aquara, The Flowing Tide',
        description: 'Guardian of Water, guiding reflection.',
        realm: ZoneTheme.Water,
        isPrimary: true,
        isNPC: true,
      ),
      Spirit(
        id: 'droplet',
        name: 'Droplet',
        description: 'A shining droplet dancing on waves.',
        realm: ZoneTheme.Water,
        isCollectible: true,
      ),
    ]);

    // Void realm
    await _box.addAll([
      Spirit(
        id: 'void_master',
        name: 'Umbra, The Silent Depth',
        description: 'Guardian of Void, keeper of secrets.',
        realm: ZoneTheme.Void,
        isPrimary: true,
        isNPC: true,
      ),
      Spirit(
        id: 'echo',
        name: 'Echo',
        description: 'A whisper from the hidden places.',
        realm: ZoneTheme.Void,
        isCollectible: true,
      ),
    ]);

    // Fusion realm
    await _box.addAll([
      Spirit(
        id: 'fusion_master',
        name: 'Synergy, The Harmonizer',
        description: 'Guardian of Fusion, blending elements.',
        realm: ZoneTheme.Fusion,
        isPrimary: true,
        isNPC: true,
      ),
      Spirit(
        id: 'prismling',
        name: 'Prismling',
        description: 'A colorful spark combining all elements.',
        realm: ZoneTheme.Fusion,
        isCollectible: true,
      ),
    ]);
  }
}
