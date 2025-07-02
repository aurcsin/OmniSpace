import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../models/spirit.dart';
import '../models/zone_theme.dart';

/// Manages seeding and lookup of Realm Spirits.
class SpiritService extends ChangeNotifier {
  SpiritService._();
  static final instance = SpiritService._();

  static const _boxName = 'spirits';
  late final Box<Spirit> _box;

  Future<void> init() async {
    // 1) Log adapter state
    debugPrint('SpiritService.init(): SpiritAdapter registered? '
               '${Hive.isAdapterRegistered(SpiritAdapter().typeId)}');

    // 2) Register if missing
    if (!Hive.isAdapterRegistered(SpiritAdapter().typeId)) {
      debugPrint('SpiritService: registering SpiritAdapter');
      Hive.registerAdapter(SpiritAdapter());
    }

    // 3) Open the box
    _box = await Hive.openBox<Spirit>(_boxName);
    debugPrint('SpiritService: opened box "$_boxName" (contains ${_box.length} entries)');

    // 4) If empty, seed one primary + a few heralds & collectables for EVERY realm
    if (_box.isEmpty) {
      debugPrint('SpiritService: box empty, seeding defaults for all realms…');
      await _seedDefaults();
      debugPrint('SpiritService: seeded ${_box.length} spirits total');
    }

    notifyListeners();
  }

  List<Spirit> get all => _box.values.toList();

  List<Spirit> forRealm(ZoneTheme realm) =>
      all.where((s) => s.realm == realm).toList();

  /// Always returns a spirit for the realm: prefers isPrimary, else falls back.
  Spirit getPrimary(ZoneTheme realm) {
    final realmList = forRealm(realm);
    if (realmList.isEmpty) {
      throw StateError('No spirits seeded for realm $realm');
    }
    return realmList.firstWhere(
      (s) => s.isPrimary,
      orElse: () => realmList.first,
    );
  }

  Future<void> _seedDefaults() async {
    // Air
    await _box.add(Spirit(
      id: 'air_master',
      name: 'Zephyr, The Whispering Wind',
      mythos: 'Guardian of Sky • Space.',
      purpose: 'Offers lofty perspective.',
      useInApp: 'Inspire aerial viewpoints in notes.',
      realm: ZoneTheme.Air,
      isPrimary: true,
      isNPC: true,
      isCollectible: false,
      archetype: 'Seeker',
      xpValue: 50,
    ));
    // Earth
    await _box.add(Spirit(
      id: 'earth_master',
      name: 'Terra, Guardian of Roots',
      mythos: 'Protector of Garden & Forest.',
      purpose: 'Anchors growth and renewal.',
      useInApp: 'Ground your ideas in stability.',
      realm: ZoneTheme.Earth,
      isPrimary: true,
      isNPC: true,
      isCollectible: false,
      archetype: 'Nurturer',
      xpValue: 50,
    ));
    // Fire
    await _box.add(Spirit(
      id: 'fire_master',
      name: 'Ignis, The Everburn',
      mythos: 'Forge & Workshop guardian.',
      purpose: 'Fuels creation with passion.',
      useInApp: 'Spark creative projects.',
      realm: ZoneTheme.Fire,
      isPrimary: true,
      isNPC: true,
      isCollectible: false,
      archetype: 'Creator',
      xpValue: 50,
    ));
    // Water
    await _box.add(Spirit(
      id: 'water_master',
      name: 'Aqua, The Deep Current',
      mythos: 'Studio & Underwater overseer.',
      purpose: 'Flows with emotional depth.',
      useInApp: 'Enhance media and reflection.',
      realm: ZoneTheme.Water,
      isPrimary: true,
      isNPC: true,
      isCollectible: false,
      archetype: 'Healer',
      xpValue: 50,
    ));
    // Void
    await _box.add(Spirit(
      id: 'void_master',
      name: 'Nyx, The Silent Shadow',
      mythos: 'Root Cave • Underground sentinel.',
      purpose: 'Comforts in stillness.',
      useInApp: 'Aid in deep archival & focus.',
      realm: ZoneTheme.Void,
      isPrimary: true,
      isNPC: true,
      isCollectible: false,
      archetype: 'Guardian',
      xpValue: 50,
    ));
    // Fusion
    await _box.add(Spirit(
      id: 'fusion_master',
      name: 'Aura, The Unifier',
      mythos: 'Bridges all realms.',
      purpose: 'Blends insights seamlessly.',
      useInApp: 'Connect journal, tracker, & projects.',
      realm: ZoneTheme.Fusion,
      isPrimary: true,
      isNPC: true,
      isCollectible: false,
      archetype: 'Catalyst',
      xpValue: 50,
    ));

    // (Optionally add heralds & collectables for each realm here…)
  }
}
