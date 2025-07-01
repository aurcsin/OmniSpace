// File: lib/services/project_service.dart

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/project.dart';

class ProjectService extends ChangeNotifier {
  ProjectService._internal();
  static final ProjectService instance = ProjectService._internal();

  static const String _boxName = 'projects';
  late final Box<Project> _box;

  /// Call once at app startup (before using any other methods).
  Future<void> init() async {
    if (!Hive.isAdapterRegistered(ProjectAdapter().typeId)) {
      Hive.registerAdapter(ProjectAdapter());
    }
    _box = await Hive.openBox<Project>(_boxName);
    notifyListeners();
  }

  /// All projects.
  List<Project> get all => _box.values.toList();

  /// Lookup by ID.
  Project? getById(String id) => _box.get(id);

  /// Create or update a project.
  Future<void> save(Project project) async {
    await _box.put(project.id, project);
    notifyListeners();
  }

  /// Permanently delete a project.
  Future<void> delete(String id) async {
    await _box.delete(id);
    notifyListeners();
  }

  /// Batch-add note IDs, avoiding duplicates.
  Future<void> addNotesToProject(String projectId, List<String> noteIds) async {
    final project = _box.get(projectId);
    if (project == null) return;
    final existing = project.noteIds.toSet()..addAll(noteIds);
    project.noteIds = existing.toList();
    await _box.put(projectId, project);
    notifyListeners();
  }

  /// Batch-remove note IDs.
  Future<void> removeNotesFromProject(String projectId, List<String> noteIds) async {
    final project = _box.get(projectId);
    if (project == null) return;
    project.noteIds.removeWhere(noteIds.contains);
    await _box.put(projectId, project);
    notifyListeners();
  }
}
