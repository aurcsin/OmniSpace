// File: lib/plugins/plugin_manager.dart

import 'plugin.dart';
import '../services/cloud_sync_service.dart';

/// Loads and registers plugins.
class PluginManager {
  PluginManager._internal();
  static final PluginManager instance = PluginManager._internal();

  final List<OmniPlugin> _plugins = [];

  void registerPlugin(OmniPlugin plugin) {
    _plugins.add(plugin);
    plugin.register(OmniPluginContext(syncService: CloudSyncService.instance));
  }

  List<OmniPlugin> get plugins => List.unmodifiable(_plugins);
}
