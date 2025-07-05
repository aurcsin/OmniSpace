// lib/pages/projects_page.dart

import 'package:flutter/material.dart';
import 'package:omnispace/models/project.dart';
import 'package:omnispace/services/project_service.dart';
import 'package:omnispace/widgets/main_menu_drawer.dart';
import 'package:omnispace/widgets/help_button.dart';

class ProjectsPage extends StatefulWidget {
  const ProjectsPage({Key? key}) : super(key: key);

  @override
  State<ProjectsPage> createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage> {
  final _svc = ProjectService.instance;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    // Initialize your Hive box
    _svc.init().then((_) {
      setState(() => _loading = false);
    });
  }

  Future<void> _showProjectDialog({Project? forEdit}) async {
    final titleCtl = TextEditingController(text: forEdit?.title ?? '');
    final result = await showDialog<String?>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(forEdit == null ? 'New Project' : 'Edit Project'),
        content: TextField(
          controller: titleCtl,
          decoration: const InputDecoration(labelText: 'Title'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, titleCtl.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      final id = forEdit?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
      final noteIds = forEdit?.noteIds ?? [];
      await _svc.save(Project(id: id, title: result, noteIds: noteIds));
      setState(() {}); // refresh list
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final projects = _svc.all;
    return Scaffold(
      drawer: const MainMenuDrawer(),
      appBar: AppBar(
        title: const Text('Projects'),
        actions: [
          HelpButton(
            helpTitle: 'Projects Help',
            helpText: '''
• Create projects to group your notes.  
• Tap a project to edit its title.  
• Long-press to delete.''',
          ),
        ],
      ),
      body: projects.isEmpty
          ? const Center(child: Text('No projects yet. Tap + to add one.'))
          : ListView.separated(
              itemCount: projects.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (ctx, i) {
                final p = projects[i];
                return ListTile(
                  title: Text(p.title),
                  subtitle: Text('${p.noteIds.length} notes'),
                  onTap: () => _showProjectDialog(forEdit: p),
                  onLongPress: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Delete Project?'),
                        content: Text('Remove project "${p.title}"?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await _svc.delete(p.id);
                      setState(() {}); // refresh list
                    }
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showProjectDialog(),
        child: const Icon(Icons.add),
        tooltip: 'New Project',
      ),
    );
  }
}
