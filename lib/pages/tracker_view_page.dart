import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/tracker.dart';
import '../models/tracker_type.dart';
import '../services/tracker_service.dart';
import '../widgets/main_menu_drawer.dart';
import 'tracker_forge_page.dart';

class TrackerViewPage extends StatefulWidget {
  final Tracker tracker;
  const TrackerViewPage({Key? key, required this.tracker})
      : super(key: key);

  @override
  _TrackerViewPageState createState() => _TrackerViewPageState();
}

class _TrackerViewPageState extends State<TrackerViewPage> {
  late Tracker _tracker;
  @override
  void initState() {
    super.initState();
    _tracker =
        TrackerService.instance.byId(widget.tracker.id) ?? widget.tracker;
  }

  Future<void> _edit() async {
    final updated = await Navigator.of(context)
        .push<Tracker>(MaterialPageRoute(
            builder: (_) =>
                TrackerForgePage(tracker: _tracker, type: _tracker.type)));
    if (updated != null) setState(() => _tracker = updated);
  }

  Widget _buildSubItems() {
    if (_tracker.childIds.isEmpty) return const SizedBox.shrink();
    return ExpansionTile(
      title: const Text('Sub-items'),
      leading: const Icon(Icons.subdirectory_arrow_right),
      children: _tracker.childIds.map((cid) {
        final c = TrackerService.instance.byId(cid);
        if (c == null) return const SizedBox.shrink();
        return CheckboxListTile(
          title: Text(c.title),
          value: c.isCompleted,
          onChanged: (_) async {
            c.toggleComplete();
            await TrackerService.instance.save(c);
            setState(() => _tracker = TrackerService.instance.byId(_tracker.id)!);
          },
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final icon = {
      TrackerType.goal: Icons.flag,
      TrackerType.event: Icons.event,
      TrackerType.routine: Icons.repeat,
      TrackerType.series: Icons.collections,
    }[_tracker.type]!;

    return Scaffold(
      drawer: const MainMenuDrawer(),
      appBar: AppBar(
        title: Text(_tracker.title),
        actions: [
          IconButton(icon: const Icon(Icons.edit), onPressed: _edit),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: Icon(icon, size: 32),
            title: Text(_tracker.title, style: const TextStyle(fontSize: 20)),
            subtitle: Text(_tracker.type.name),
          ),
          if (_tracker.type == TrackerType.goal) ...[
            ListTile(
              leading: const Icon(Icons.assessment),
              title: Text(
                  'Progress: ${( (_tracker.progress ?? 0) * 100 ).round()}%'),
            ),
          ],
          if (_tracker.type == TrackerType.event) ...[
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text(_tracker.start != null
                  ? DateFormat.yMMMd().format(_tracker.start!)
                  : 'No date'),
            ),
          ],
          if (_tracker.type == TrackerType.routine) ...[
            ListTile(
              leading: const Icon(Icons.repeat),
              title:
                  Text('Recurs: ${_tracker.frequency ?? '(not set)'}'),
            ),
          ],
          if (_tracker.type == TrackerType.series) ...[
            ListTile(
              leading: const Icon(Icons.link),
              title: Text(
                  'Items: ${_tracker.childIds.length}'),
            ),
          ],
          const Divider(),
          _buildSubItems(),
        ],
      ),
    );
  }
}
