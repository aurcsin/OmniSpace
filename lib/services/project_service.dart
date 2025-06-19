// File: lib/services/project_service.dart

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/project.dart';

class ProjectService extends ChangeNotifier {
  ProjectService._internal();
  static final ProjectService instance = ProjectService._internal();

  static const String _boxName = 'projects';
  late Box<Project> _box;

  Future<void> init() async {
    if (!Hive.isAdapterRegistered(ProjectAdapter().typeId)) {
      Hive.registerAdapter(ProjectAdapter());
    }
    _box = await Hive.openBox<Project>(_boxName);
    notifyListeners();
  }

  List<Project> get all => _box.values.toList();

  Project? getById(String id) => _box.get(id);

  Future<void> save(Project project) async {
    await _box.put(project.id, project);
    notifyListeners();
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
    notifyListeners();
  }

  /// Batch-add note IDs to a project
  Future<void> addNotesToProject(String projectId, List<String> noteIds) async {
    final project = _box.get(projectId);
    if (project != null) {
      final existing = List<String>.from(project.noteIds);
      for (var id in noteIds) {
        if (!existing.contains(id)) existing.add(id);
      }
      project.noteIds = existing;
      await _box.put(projectId, project);
      notifyListeners();
    }
  }
}
