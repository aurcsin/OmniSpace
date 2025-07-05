// lib/pages/root_cave_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:omnispace/models/omni_note.dart';
import 'package:omnispace/services/omni_note_service.dart';
import 'package:omnispace/widgets/main_menu_drawer.dart';
import 'package:omnispace/pages/note_detail_page.dart';

class RootCavePage extends StatefulWidget {
  const RootCavePage({Key? key}) : super(key: key);

  @override
  State<RootCavePage> createState() => _RootCavePageState();
}

class _RootCavePageState extends State<RootCavePage> with SingleTickerProviderStateMixin {
  final _noteSvc = OmniNoteService.instance;
  late TabController _tabController;

  List<OmniNote> get _archived =>
      _noteSvc.notes.where((n) => n.isArchived && !n.isTrashed).toList()
        ..sort((a, b) => b.lastUpdated.compareTo(a.lastUpdated));

  List<OmniNote> get _trashed =>
      _noteSvc.notes.where((n) => n.isTrashed).toList()
        ..sort((a, b) => b.lastUpdated.compareTo(a.lastUpdated));

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  Future<void> _restore(OmniNote note) async {
    if (_tabController.index == 0) {
      note.isArchived = false;
    } else {
      note.isTrashed = false;
    }
    await _noteSvc.save(note);
    setState(() {});
  }

  Future<void> _openNote(OmniNote note) async {
    if (note.isLocked) {
      final pw = await showDialog<String>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Unlock Note'),
          content: TextField(
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Password'),
            onSubmitted: (v) => Navigator.of(context).pop(v),
          ),
        ),
      );
      if (pw != note.lockPassword) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Wrong password')));
        return;
      }
    }
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => NoteDetailPage(omniNote: note)),
    );
    if (saved == true) setState(() {});
  }

  Widget _buildList(List<OmniNote> notes) {
    if (notes.isEmpty) {
      return const Center(child: Text('Nothing here.'));
    }
    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (_, i) {
        final n = notes[i];
        return Dismissible(
          key: ValueKey(n.id),
          background: Container(
            color: Colors.green,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 16),
            child: const Icon(Icons.undo, color: Colors.white),
          ),
          secondaryBackground: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16),
            child: const Icon(Icons.delete_forever, color: Colors.white),
          ),
          confirmDismiss: (direction) async {
            if (direction == DismissDirection.startToEnd) {
              await _restore(n);
              return false;
            } else {
              final ok = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Delete Permanently?'),
                  content: const Text('This cannot be undone.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                    ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
                  ],
                ),
              );
              if (ok == true) {
                await n.delete();
                return true;
              }
              return false;
            }
          },
          onDismissed: (_) => setState(() {}),
          child: ListTile(
            leading: Icon(n.isLocked ? Icons.lock : Icons.note,
                color: n.isLocked ? Colors.grey : null),
            title: Text(n.title.isEmpty ? '(No Title)' : n.title),
            subtitle: Text(DateFormat.yMMMd().add_jm().format(n.lastUpdated)),
            onTap: () => _openNote(n),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MainMenuDrawer(),
      appBar: AppBar(
        title: const Text('Root Cave'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Archived'),
            Tab(text: 'Trash'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildList(_archived),
          _buildList(_trashed),
        ],
      ),
    );
  }
}
