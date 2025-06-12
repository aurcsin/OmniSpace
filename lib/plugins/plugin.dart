// File: lib/plugins/plugin.dart

import '../services/cloud_sync_service.dart';

/// Context passed to plugins for interacting with the app.
class OmniPluginContext {
  final CloudSyncService syncService;
  OmniPluginContext({required this.syncService});
}

/// Base class for community plugins.
abstract class OmniPlugin {
  String get name;

  void register(OmniPluginContext context);
}
