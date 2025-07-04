// lib/models/sync_metadata.dart

import 'package:hive_flutter/hive_flutter.dart';

part 'sync_metadata.g.dart';

@HiveType(typeId: 1)
class SyncMetadata extends HiveObject {
  @HiveField(0)
  DateTime? lastSyncedAt;

  SyncMetadata({this.lastSyncedAt});

  /// Initialize Hive, register adapter, and open the box.
  static Future<void> init() async {
    // Only initialize Hive once in your app (e.g. in main.dart before runApp)
    await Hive.initFlutter();
    // Register the generated adapter
    Hive.registerAdapter(SyncMetadataAdapter());
    // Open the box where SyncMetadata will be stored
    await Hive.openBox<SyncMetadata>('sync_metadata');
  }

  /// Load the sole SyncMetadata instance, or return a fresh one.
  static Future<SyncMetadata> load() async {
    final box = Hive.box<SyncMetadata>('sync_metadata');
    if (box.isEmpty) {
      return SyncMetadata();
    }
    return box.getAt(0)!;
  }

  /// Save (or update) this instance as the sole entry.
  Future<void> save() async {
    final box = Hive.box<SyncMetadata>('sync_metadata');
    if (box.isEmpty) {
      await box.add(this);
    } else {
      await box.putAt(0, this);
    }
  }
}
