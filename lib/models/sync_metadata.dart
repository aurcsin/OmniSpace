// File: lib/models/sync_metadata.dart

import 'package:hive/hive.dart';

part 'sync_metadata.g.dart';

/// Stores metadata for synchronization (e.g., last sync timestamp).
@HiveType(typeId: 9)
class SyncMetadata extends HiveObject {
  @HiveField(0)
  DateTime? lastSyncedAt;

  SyncMetadata({this.lastSyncedAt});

  /// Load existing metadata from Hive or create a new one if none exists.
  static Future<SyncMetadata> load() async {
    const boxName = 'sync_metadata';
    final box = await Hive.openBox<SyncMetadata>(boxName);
    if (box.isEmpty) {
      final meta = SyncMetadata();
      await box.put('metadata', meta);
      return meta;
    }
    return box.get('metadata')!;
  }

  /// Persist this metadata instance to Hive.
  Future<void> save() async {
    const boxName = 'sync_metadata';
    final box = await Hive.openBox<SyncMetadata>(boxName);
    await box.put('metadata', this);
  }
}
