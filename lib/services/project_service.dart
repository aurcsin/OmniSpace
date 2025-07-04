// lib/services/project_service.dart

import 'package:hive/hive.dart';
import '../models/project.dart';

class ProjectService {
  ProjectService._();
  static final instance = ProjectService._();

  static const _boxName = 'projects';
  late Box<Project> _box;
  final List<Project> _projects = [];

  /// Call once at app startup to open the Hive box and load all projects.
  Future<void> init() async {
    _box = await Hive.openBox<Project>(_boxName);
    _projects
      ..clear()
      ..addAll(_box.values);
  }

  /// All projects in memory.
  List<Project> get all => List.unmodifiable(_projects);

  /// Lookup a project by ID.
  Project? getById(String id) => _box.get(id);

  /// Save or update a project.
  Future<void> save(Project project) async {
    await _box.put(project.id, project);
    final idx = _projects.indexWhere((p) => p.id == project.id);
    if (idx >= 0) {
      _projects[idx] = project;
    } else {
      _projects.add(project);
    }
  }

  /// Delete a project.
  Future<void> delete(String id) async {
    await _box.delete(id);
    _projects.removeWhere((p) => p.id == id);
  }
}
