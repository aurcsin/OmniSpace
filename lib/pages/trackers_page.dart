import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../models/goal.dart';
import '../models/event.dart';
import '../services/trackers_service.dart';
import '../widgets/main_menu_drawer.dart';

class TrackersPage extends StatefulWidget {
  const TrackersPage({super.key});

  @override
  State<TrackersPage> createState() => _TrackersPageState();
}

class _TrackersPageState extends State<TrackersPage> {
  @override
  void initState() {
    super.initState();
    if (!TrackersService.instance.isInitialized) {
      TrackersService.instance.init();
    }
  }

  Future<void> _addTask() async {
    final descCtl = TextEditingController();
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('New Task'),
        content: TextField(
          controller: descCtl,
          decoration: const InputDecoration(labelText: 'Description'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final text = descCtl.text.trim();
              if (text.isNotEmpty) {
                await TrackersService.instance
                    .addTask(Task(description: text));
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    descCtl.dispose();
  }

  Future<void> _addGoal() async {
    final titleCtl = TextEditingController();
    final descCtl = TextEditingController();
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('New Goal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtl,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: descCtl,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final title = titleCtl.text.trim();
              final desc = descCtl.text.trim();
              if (title.isNotEmpty) {
                await TrackersService.instance.addGoal(
                  Goal(title: title, description: desc.isEmpty ? null : desc),
                );
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    titleCtl.dispose();
    descCtl.dispose();
  }

  Future<void> _addEvent() async {
    final titleCtl = TextEditingController();
    DateTime date = DateTime.now();
    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('New Event'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtl,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(DateFormat.yMd().format(date)),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                        initialDate: date,
                      );
                      if (picked != null) {
                        setState(() => date = picked);
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final title = titleCtl.text.trim();
                if (title.isNotEmpty) {
                  await TrackersService.instance.addEvent(
                    Event(title: title, eventDate: date),
                  );
                }
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
    titleCtl.dispose();
  }

  Widget _buildTasks() {
    final tasks = TrackersService.instance.tasks;
    return ExpansionTile(
      title: const Text('Tasks'),
      children: [
        if (tasks.isEmpty)
          const ListTile(title: Text('No tasks yet.'))
        else
          ...tasks.map(
            (t) => CheckboxListTile(
              value: t.isCompleted,
              title: Text(t.description),
              onChanged: (val) async {
                t.isCompleted = val ?? false;
                await TrackersService.instance.updateTask(t);
                setState(() {});
              },
            ),
          ),
        TextButton.icon(
          onPressed: _addTask,
          icon: const Icon(Icons.add),
          label: const Text('Add Task'),
        ),
      ],
    );
  }

  Widget _buildGoals() {
    final goals = TrackersService.instance.goals;
    return ExpansionTile(
      title: const Text('Goals'),
      children: [
        if (goals.isEmpty)
          const ListTile(title: Text('No goals yet.'))
        else
          ...goals.map(
            (g) => ListTile(
              title: Text(g.title),
              subtitle: g.description != null ? Text(g.description!) : null,
            ),
          ),
        TextButton.icon(
          onPressed: _addGoal,
          icon: const Icon(Icons.add),
          label: const Text('Add Goal'),
        ),
      ],
    );
  }

  Widget _buildEvents() {
    final events = TrackersService.instance.events;
    return ExpansionTile(
      title: const Text('Events'),
      children: [
        if (events.isEmpty)
          const ListTile(title: Text('No events yet.'))
        else
          ...events.map(
            (e) => ListTile(
              title: Text(e.title),
              subtitle: Text(DateFormat.yMd().format(e.eventDate)),
            ),
          ),
        TextButton.icon(
          onPressed: _addEvent,
          icon: const Icon(Icons.add),
          label: const Text('Add Event'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<TrackersService>.value(
      value: TrackersService.instance,
      child: Consumer<TrackersService>(
        builder: (_, __, ___) => Scaffold(
          drawer: const MainMenuDrawer(),
          appBar: AppBar(title: const Text('Trackers')),
          body: ListView(
            padding: const EdgeInsets.all(8),
            children: [
              _buildTasks(),
              const SizedBox(height: 8),
              _buildGoals(),
              const SizedBox(height: 8),
              _buildEvents(),
            ],
          ),
        ),
      ),
    );
  }
}
