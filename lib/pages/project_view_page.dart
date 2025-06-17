import 'package:flutter/material.dart';
import '../models/project.dart';
import '../services/project_service.dart';
import 'project_forge_page.dart';
import '../widgets/main_menu_drawer.dart';
import '../widgets/object_card.dart';

class ProjectViewPage extends StatefulWidget {
  final Project project;
  const ProjectViewPage({super.key, required this.project});

  @override
  _ProjectViewPageState createState() => _ProjectViewPageState();
}

class _ProjectViewPageState extends State<ProjectViewPage> {
  late Project _project;

  @override
  void initState() {
    super.initState();
    _project = widget.project;
  }

  Future<void> _edit() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProjectForgePage(project: _project),
      ),
    );
    final reloaded = ProjectService.instance.byId(_project.id);
    if (reloaded != null) setState(() => _project = reloaded);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MainMenuDrawer(),
      appBar: AppBar(
        title: Text(
          _project.title.isNotEmpty ? _project.title : '(Untitled Project)',
        ),
        actions: [
          IconButton(icon: const Icon(Icons.edit), onPressed: _edit),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: ObjectCard(project: _project),
      ),
    );
  }
}
