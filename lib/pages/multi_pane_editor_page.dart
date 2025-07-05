// lib/pages/multi_pane_editor_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:omnispace/models/omni_note.dart';
import 'package:omnispace/services/omni_note_service.dart';
import 'package:omnispace/widgets/help_button.dart';
import 'package:omnispace/widgets/main_menu_drawer.dart';

class MultiPaneEditorPage extends StatefulWidget {
  final OmniNote note;
  const MultiPaneEditorPage(this.note, {Key? key}) : super(key: key);

  @override
  State<MultiPaneEditorPage> createState() => _MultiPaneEditorPageState();
}

class _MultiPaneEditorPageState extends State<MultiPaneEditorPage> {
  final _svc = OmniNoteService.instance;
  late OmniNote _note;
  late TextEditingController _titleCtl;
  late TextEditingController _contentCtl;

  @override
  void initState() {
    super.initState();
    _note = widget.note;
    _titleCtl   = TextEditingController(text: _note.title);
    _contentCtl = TextEditingController(text: _note.content);
  }

  @override
  void dispose() {
    _titleCtl.dispose();
    _contentCtl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    _note
      ..title       = _titleCtl.text.trim()
      ..content     = _contentCtl.text.trim()
      ..lastUpdated = DateTime.now();
    await _svc.save(_note);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Note saved')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MainMenuDrawer(),
      appBar: AppBar(
        title: const Text('Edit Note'),
        actions: [
          HelpButton(
            helpTitle: 'Editor Help',
            helpText: '''
• Modify your note title and content side-by-side.  
• Tap Save to persist.''',
          ),
          IconButton(icon: const Icon(Icons.save), onPressed: _save),
        ],
      ),
      body: LayoutBuilder(builder: (ctx, bc) {
        // Two-pane if width >= 600
        final isWide = bc.maxWidth >= 600;
        if (isWide) {
          return Row(
            children: [
              Expanded(child: _buildTitlePane()),
              const VerticalDivider(width: 1),
              Expanded(child: _buildContentPane()),
            ],
          );
        } else {
          return ListView(
            children: [
              _buildTitlePane(),
              const Divider(),
              _buildContentPane(),
            ],
          );
        }
      }),
    );
  }

  Widget _buildTitlePane() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Title', style: TextStyle(fontWeight: FontWeight.bold)),
        TextField(controller: _titleCtl, decoration: const InputDecoration(hintText: 'Title…')),
        const SizedBox(height: 16),
        Text(
          'Last updated: ${DateFormat.yMMMd().add_jm().format(_note.lastUpdated)}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ]),
    );
  }

  Widget _buildContentPane() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Content', style: TextStyle(fontWeight: FontWeight.bold)),
        Expanded(
          child: TextField(
            controller: _contentCtl,
            decoration: const InputDecoration(hintText: 'Write your thoughts…'),
            maxLines: null,
            expands: true,
          ),
        ),
      ]),
    );
  }
}
