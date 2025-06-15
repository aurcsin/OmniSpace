import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/project.dart';

class ProjectService extends ChangeNotifier {
  ProjectService._();
  static final ProjectService instance = ProjectService._();

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

  Project? byId(String id) => _box.get(id);

  Future<void> save(Project project) async {
    await _box.put(project.id, project);
    notifyListeners();
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
    notifyListeners();
  }
}
