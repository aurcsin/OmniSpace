// File: lib/pages/projects_page.dart

import 'package:flutter/material.dart';
import '../models/project.dart';
import '../services/project_service.dart';
import 'project_forge_page.dart';

class ProjectsPage extends StatefulWidget {
  const ProjectsPage({Key? key}) : super(key: key);

  @override
  State<ProjectsPage> createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage> {
  List<Project> get _all => ProjectService.instance.all;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Projects'),
      ),
      body: _all.isEmpty
          ? const Center(child: Text('No projects yet.'))
          : ListView.separated(
              itemCount: _all.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final project = _all[index];
                return ListTile(
                  title: Text(project.title), // <-- use .title instead of .name
                  onTap: () => Navigator.of(context)
                      .push(MaterialPageRoute(
                        builder: (_) => ProjectForgePage(project: project),
                      ))
                      .then((_) => setState(() {})),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => Navigator.of(context)
                        .push(MaterialPageRoute(
                          builder: (_) => ProjectForgePage(project: project),
                        ))
                        .then((_) => setState(() {})),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => Navigator.of(context)
            .push(MaterialPageRoute(
              builder: (_) => const ProjectForgePage(),
            ))
            .then((_) => setState(() {})),
      ),
    );
  }
}
