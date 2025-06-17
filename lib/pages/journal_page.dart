// File: lib/pages/journal_page.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../models/omni_note.dart';
import '../models/attachment.dart';
import '../services/omni_note_service.dart';
import '../widgets/main_menu_drawer.dart';
import 'note_detail_page.dart';
import 'calendar_overview_page.dart';

enum JournalSort { chronoDesc, chronoAsc, alphaAsc, alphaDesc }

class JournalPage extends StatefulWidget {
  const JournalPage({super.key});

  @override
  _JournalPageState createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  List<OmniNote> _notes = [];
  bool _loading = true;
  bool _gridMode = true;

  String _searchQuery = '';
  JournalSort _sort = JournalSort.chronoDesc;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    setState(() => _loading = true);
    await OmniNoteService.instance.loadAllNotes();
    _notes = OmniNoteService.instance.notes;
    setState(() => _loading = false);
  }

  List<OmniNote> get _filteredSorted {
    final q = _searchQuery.toLowerCase();
    var list = _notes.where((n) {
      return n.title.toLowerCase().contains(q) ||
          n.subtitle.toLowerCase().contains(q) ||
          n.content.toLowerCase().contains(q) ||
          n.tags.toLowerCase().contains(q);
    }).toList();
    switch (_sort) {
      case JournalSort.chronoDesc:
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case JournalSort.chronoAsc:
        list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case JournalSort.alphaAsc:
        list.sort((a, b) => a.title.compareTo(b.title));
        break;
      case JournalSort.alphaDesc:
        list.sort((a, b) => b.title.compareTo(a.title));
        break;
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MainMenuDrawer(),
      appBar: AppBar(
        title: const Text('Journal'),
        actions: [
          PopupMenuButton<JournalSort>(
            icon: const Icon(Icons.sort),
            onSelected: (s) => setState(() => _sort = s),
            itemBuilder: (_) => const [
              PopupMenuItem(
                  value: JournalSort.chronoDesc,
                  child: Text('Newest first')),
              PopupMenuItem(
                  value: JournalSort.chronoAsc,
                  child: Text('Oldest first')),
              PopupMenuItem(
                  value: JournalSort.alphaAsc, child: Text('A → Z')),
              PopupMenuItem(
                  value: JournalSort.alphaDesc, child: Text('Z → A')),
            ],
          ),
          IconButton(
            icon: Icon(_gridMode ? Icons.list : Icons.grid_view),
            onPressed: () => setState(() => _gridMode = !_gridMode),
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (_) => const CalendarOverviewPage()),
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Search bar
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: TextField(
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Search notes…',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) => setState(() => _searchQuery = v),
                  ),
                ),
                Expanded(
                  child: _filteredSorted.isEmpty
                      ? Center(
                          child: Text(
                            _searchQuery.isEmpty
                                ? 'No notes yet.'
                                : 'No match.',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(8),
                          child: _gridMode
                              ? MasonryGridView.count(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 8,
                                  crossAxisSpacing: 8,
                                  itemCount: _filteredSorted.length,
                                  itemBuilder: (_, i) {
                                    final note = _filteredSorted[i];
                                    return GestureDetector(
                                      onTap: () => Navigator.of(context)
                                          .push(
                                            MaterialPageRoute(
                                              builder: (_) => NoteDetailPage(
                                                  omniNote: note),
                                            ),
                                          )
                                          .then((_) => _loadNotes()),
                                      child: _NoteCard(note: note),
                                    );
                                  },
                                )
                              : ListView.separated(
                                  itemCount: _filteredSorted.length,
                                  separatorBuilder: (_, __) =>
                                      const Divider(height: 1),
                                  itemBuilder: (_, i) {
                                    final note = _filteredSorted[i];
                                    return _NoteListTile(
                                      note: note,
                                      onTap: () => Navigator.of(context)
                                          .push(
                                            MaterialPageRoute(
                                              builder: (_) => NoteDetailPage(
                                                  omniNote: note),
                                            ),
                                          )
                                          .then((_) => _loadNotes()),
                                    );
                                  },
                                ),
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => Navigator.of(context)
            .push(
              MaterialPageRoute(
                  builder: (_) =>
                      const NoteDetailPage(omniNote: null)),
            )
            .then((_) => _loadNotes()),
      ),
    );
  }
}

/// A small “card” for grid view.
class _NoteCard extends StatelessWidget {
  final OmniNote note;
  const _NoteCard({required this.note});

  @override
  Widget build(BuildContext context) {
    final hasImage =
        note.attachments.any((a) => a.type == AttachmentType.image);
    final hasAudio =
        note.attachments.any((a) => a.type == AttachmentType.audio);
    final hasVideo =
        note.attachments.any((a) => a.type == AttachmentType.video);
    final color = Color(note.colorValue);

    return Container(
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: color, width: 4)),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasImage)
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(5)),
              child: Image.file(
                File(note
                    .attachments
                    .firstWhere((a) => a.type == AttachmentType.image)
                    .localPath),
                fit: BoxFit.cover,
                width: double.infinity,
                height: 120,
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              note.title.isNotEmpty ? note.title : '(No Title)',
              style: const TextStyle(fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                if (hasImage) const Icon(Icons.image, size: 16),
                if (hasAudio) const Icon(Icons.mic, size: 16),
                if (hasVideo) const Icon(Icons.videocam, size: 16),
                const Spacer(),
                Text(
                  TimeOfDay.fromDateTime(note.createdAt).format(context),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Simple ListTile for list view.
class _NoteListTile extends StatelessWidget {
  final OmniNote note;
  final VoidCallback onTap;
  const _NoteListTile({required this.note, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hasImage =
        note.attachments.any((a) => a.type == AttachmentType.image);
    final hasAudio =
        note.attachments.any((a) => a.type == AttachmentType.audio);
    final hasVideo =
        note.attachments.any((a) => a.type == AttachmentType.video);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Color(note.colorValue),
        child: hasImage
            ? const Icon(Icons.image)
            : hasAudio
                ? const Icon(Icons.mic)
                : hasVideo
                    ? const Icon(Icons.videocam)
                    : const Icon(Icons.text_snippet),
      ),
      title: Text(note.title.isNotEmpty ? note.title : '(No Title)'),
      subtitle: Text(note.subtitle),
      trailing: Text(
        TimeOfDay.fromDateTime(note.createdAt).format(context),
        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
      ),
      onTap: onTap,
    );
  }
}
