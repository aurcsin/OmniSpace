// File: lib/services/project_service.dart

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/project.dart';

class ProjectService extends ChangeNotifier {
  ProjectService._internal();
  static final ProjectService instance = ProjectService._internal();

  static const String _boxName = 'projects';
  late Box<Project> _box;

  /// Initialize Hive box and adapters. Call this once at startup.
  Future<void> init() async {
    if (!Hive.isAdapterRegistered(ProjectAdapter().typeId)) {
      Hive.registerAdapter(ProjectAdapter());
    }
    _box = await Hive.openBox<Project>(_boxName);
    notifyListeners();
  }

  /// All projects
  List<Project> get all => _box.values.toList();

  /// Lookup project by ID
  Project? getById(String id) => _box.get(id);

  /// Create or update a project
  Future<void> save(Project project) async {
    await _box.put(project.id, project);
    notifyListeners();
  }

  /// Delete a project permanently
  Future<void> delete(String id) async {
    await _box.delete(id);
    notifyListeners();
  }

  /// Delete multiple
  Future<void> deleteMultiple(List<String> ids) async {
    for (var id in ids) {
      await _box.delete(id);
    }
    notifyListeners();
  }
}
