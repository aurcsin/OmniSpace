import 'package:flutter/material.dart';
import '../models/omni_note.dart';
import '../services/omni_note_service.dart';
import '../services/secure_storage_service.dart';
import '../widgets/main_menu_drawer.dart';
import '../widgets/object_card.dart';
import 'note_detail_page.dart';

class NoteViewPage extends StatefulWidget {
  final OmniNote note;
  const NoteViewPage({super.key, required this.note});

  @override
  _NoteViewPageState createState() => _NoteViewPageState();
}

class _NoteViewPageState extends State<NoteViewPage>
    with SingleTickerProviderStateMixin {
  late OmniNote _note;
  late AnimationController _pinAnim;
  bool _locked = false;

  @override
  void initState() {
    super.initState();
    _note = widget.note;
    _pinAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _loadLockState();
  }

  @override
  void dispose() {
    _pinAnim.dispose();
    super.dispose();
  }

  Future<void> _loadLockState() async {
    final pwd = await SecureStorageService.instance.read('lock_${_note.id}');
    setState(() => _locked = pwd != null);
    if (_locked) _promptUnlock();
  }

  Future<void> _togglePin() async {
    if (_pinAnim.status == AnimationStatus.completed) {
      _pinAnim.reverse();
    } else {
      _pinAnim.forward();
    }
    setState(() => _note.isPinned = !_note.isPinned);
    await OmniNoteService.instance.saveNote(_note);
  }

  Future<void> _toggleLock() async {
    if (_locked) {
      await _promptUnlock();
    } else {
      await _promptLock();
    }
  }

  Future<void> _promptLock() async {
    final ctrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Lock Note'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(labelText: 'Password'),
          obscureText: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Lock')),
        ],
      ),
    );
    if (ok == true && ctrl.text.isNotEmpty) {
      await SecureStorageService.instance.write('lock_${_note.id}', ctrl.text);
      setState(() => _locked = true);
    }
  }

  Future<void> _promptUnlock() async {
    final ctrl = TextEditingController();
    final correct = await SecureStorageService.instance.read('lock_${_note.id}') ?? '';
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Unlock Note'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(labelText: 'Password'),
          obscureText: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Unlock')),
        ],
      ),
    );
    if (ok == true && ctrl.text == correct) {
      await SecureStorageService.instance.delete('lock_${_note.id}');
      setState(() => _locked = false);
    } else if (ok == true) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Wrong password')));
    }
  }

  Future<void> _edit() async {
    if (_locked) {
      await _promptUnlock();
      if (_locked) return; // still locked
    }
    await Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => NoteDetailPage(omniNote: _note)));
    final reloaded = OmniNoteService.instance.getNoteById(_note.id);
    if (reloaded != null) setState(() => _note = reloaded);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MainMenuDrawer(),
      appBar: AppBar(
        title: Text(_note.title.isNotEmpty ? _note.title : '(Untitled)'),
        actions: [
          IconButton(
            icon: AnimatedIcon(
              icon: AnimatedIcons.add_event,
              progress: _pinAnim,
            ),
            tooltip: _note.isPinned ? 'Unpin' : 'Pin',
            onPressed: _togglePin,
          ),
          IconButton(
            icon: Icon(_locked ? Icons.lock : Icons.lock_open),
            tooltip: _locked ? 'Unlock' : 'Lock',
            onPressed: _toggleLock,
          ),
          IconButton(icon: const Icon(Icons.edit), onPressed: _edit),
        ],
      ),
      body: _locked
          ? const Center(child: Text('🔒 Note is Locked', style: TextStyle(fontSize: 24)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ObjectCard(note: _note),
            ),
    );
  }
}
