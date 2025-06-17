import 'package:flutter/material.dart';
import '../services/project_service.dart';
import '../models/project.dart';
import 'project_view_page.dart';
import 'project_forge_page.dart';
import '../widgets/main_menu_drawer.dart';

class WorkshopForgePage extends StatelessWidget {
  const WorkshopForgePage({super.key});

  @override
  Widget build(BuildContext context) {
    final projects = ProjectService.instance.all;
    return Scaffold(
      drawer: const MainMenuDrawer(),
      appBar: AppBar(title: const Text('Workshop / Forge')),
      body: projects.isEmpty
          ? const Center(child: Text('No projects yet.'))
          : ListView.builder(
              itemCount: projects.length,
              itemBuilder: (_, i) {
                final Project p = projects[i];
                return ListTile(
                  title: Text(p.title.isNotEmpty ? p.title : 'Untitled Project'),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ProjectViewPage(project: p),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ProjectForgePage()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
