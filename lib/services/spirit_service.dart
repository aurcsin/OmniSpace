// lib/services/spirit_service.dart

import 'package:hive/hive.dart';
import '../models/spirit.dart';
import '../models/zone_theme.dart';

class SpiritService {
  SpiritService._();
  static final instance = SpiritService._();

  static const _boxName = 'spirits';
  late Box<Spirit> _box;
  final List<Spirit> _spirits = [];

  /// Call once at app startup to open the Hive box and load all spirits.
  Future<void> init() async {
    _box = await Hive.openBox<Spirit>(_boxName);
    _spirits
      ..clear()
      ..addAll(_box.values);
  }

  /// All spirits.
  List<Spirit> get all => List.unmodifiable(_spirits);

  /// Lookup a spirit by ID.
  Spirit? getById(String id) => _box.get(id);

  /// All master (primary) spirits.
  List<Spirit> getPrimaries() =>
      _spirits.where((s) => s.isPrimary).toList();

  /// All collectible (non-primary, non-NPC) spirits.
  List<Spirit> getCollectibles() =>
      _spirits.where((s) => s.isCollectible).toList();

  /// All spirits in a given realm.
  List<Spirit> getByRealm(ZoneTheme realm) =>
      _spirits.where((s) => s.realm == realm).toList();
}
