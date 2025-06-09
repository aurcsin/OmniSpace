// File: lib/pages/journal_page.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'package:omnispace/models/omni_note.dart';
import 'package:omnispace/models/attachment.dart';
import 'package:omnispace/services/omni_note_service.dart';

// Alias note_detail_page to avoid name conflicts
import 'note_detail_page.dart' as detail;
import 'calendar_overview_page.dart';
import 'package:omnispace/widgets/main_menu_drawer.dart';


/// JournalPage shows all notes either in a grid or list.
class JournalPage extends StatefulWidget {
  const JournalPage({super.key});

  @override
  _JournalPageState createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  String _searchQuery = '';
  bool _isLoading = true;
  bool _gridMode = true;
  List<OmniNote> _displayedNotes = [];

  @override
  void initState() {
    super.initState();
    _initializeNotes();
  }

  Future<void> _initializeNotes() async {
    await OmniNoteService.instance.loadAllNotes();
    setState(() {
      _displayedNotes = OmniNoteService.instance.notes;
      _isLoading = false;
    });
  }

  Future<void> _performSearch(String query) async {
    setState(() {
      _searchQuery = query;
      _isLoading = true;
    });
    final results = await OmniNoteService.instance.searchNotes(query);
    setState(() {
      _displayedNotes = results;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<OmniNoteService>.value(
      value: OmniNoteService.instance,
      child: Consumer<OmniNoteService>(
        builder: (_, __, ___) {
          final notes = _displayedNotes;
          return Scaffold(
            drawer: const MainMenuDrawer(),
            appBar: AppBar(
              title: const Text('Journal'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const CalendarOverviewPage(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(_gridMode ? Icons.list : Icons.grid_view),
                  onPressed: () => setState(() => _gridMode = !_gridMode),
                ),
              ],
            ),
            body: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.search),
                            hintText: 'Search…',
                          ),
                          onChanged: _performSearch,
                        ),
                      ),
                      Expanded(
                        child: notes.isEmpty
                            ? Center(
                                child: Text(
                                  _searchQuery.isEmpty
                                      ? 'No notes yet.\nTap + to create one.'
                                      : 'No notes match your search.',
                                  textAlign: TextAlign.center,
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
                                        itemCount: notes.length,
                                        itemBuilder: (_, i) {
                                          final note = notes[i];
                                          return _NoteCard(
                                            note: note,
                                            onTap: () => Navigator.of(context)
                                                .push(
                                                  MaterialPageRoute(
                                                    builder: (_) => detail.NoteDetailPage(
                                                        omniNote: note),
                                                  ),
                                                )
                                                .then((_) => _initializeNotes()),
                                          );
                                        },
                                      )
                                    : ListView.separated(
                                        itemCount: notes.length,
                                        separatorBuilder: (_, __) =>
                                            const Divider(height: 1),
                                        itemBuilder: (_, i) {
                                          final note = notes[i];
                                          return _NoteListTile(
                                            note: note,
                                            onTap: () => Navigator.of(context)
                                                .push(
                                                  MaterialPageRoute(
                                                    builder: (_) => detail.NoteDetailPage(
                                                        omniNote: note),
                                                  ),
                                                )
                                                .then((_) => _initializeNotes()),
                                          );
                                        },
                                      ),
                              ),
                      ),
                    ],
                  ),
            floatingActionButton: FloatingActionButton(
              child: const Icon(Icons.add),
              onPressed: () => _showCreateNoteOptions(context),
            ),
          );
        },
      ),
    );
  }

  void _showCreateNoteOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Wrap(
          alignment: WrapAlignment.center,
          children: [
            _buildOptionIcon(
              icon: Icons.text_fields,
              label: 'Text Note',
              color: Colors.deepOrange,
              onTap: () {
                Navigator.of(ctx).pop();
                Navigator.of(context)
                    .push(MaterialPageRoute(
                      builder: (_) => const detail.NoteDetailPage(
                          initialMode: detail.NoteMode.text),
                    ))
                    .then((_) => _initializeNotes());
              },
            ),
            _buildOptionIcon(
              icon: Icons.mic,
              label: 'Voice Note',
              color: Colors.redAccent,
              onTap: () {
                Navigator.of(ctx).pop();
                Navigator.of(context)
                    .push(MaterialPageRoute(
                      builder: (_) => const detail.NoteDetailPage(
                          initialMode: detail.NoteMode.voice),
                    ))
                    .then((_) => _initializeNotes());
              },
            ),
            _buildOptionIcon(
              icon: Icons.camera_alt,
              label: 'Image Note',
              color: Colors.teal,
              onTap: () {
                Navigator.of(ctx).pop();
                Navigator.of(context)
                    .push(MaterialPageRoute(
                      builder: (_) => const detail.NoteDetailPage(
                          initialMode: detail.NoteMode.image),
                    ))
                    .then((_) => _initializeNotes());
              },
            ),
            _buildOptionIcon(
              icon: Icons.videocam,
              label: 'Video Note',
              color: Colors.blueAccent,
              onTap: () {
                Navigator.of(ctx).pop();
                Navigator.of(context)
                    .push(MaterialPageRoute(
                      builder: (_) => const detail.NoteDetailPage(
                          initialMode: detail.NoteMode.video),
                    ))
                    .then((_) => _initializeNotes());
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionIcon({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: color.withOpacity(0.1),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(height: 8),
              Text(label),
            ],
          ),
        ),
      );
}

/// A small “card” for grid view.
class _NoteCard extends StatelessWidget {
  final OmniNote note;
  final VoidCallback onTap;
  const _NoteCard({required this.note, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hasImage =
        note.attachments.any((a) => a.type == AttachmentType.image);
    final hasAudio =
        note.attachments.any((a) => a.type == AttachmentType.audio);
    final hasVideo =
        note.attachments.any((a) => a.type == AttachmentType.video);
    final hasText = note.title.isNotEmpty || note.content.isNotEmpty;
    final color = Color(note.colorValue);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: color, width: 5)),
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
                  File(
                    note.attachments
                        .firstWhere((a) => a.type == AttachmentType.image)
                        .localPath,
                  ),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 150,
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 4,
                children: [
                  if (hasText) const Icon(Icons.text_snippet, size: 16),
                  if (hasAudio) const Icon(Icons.mic, size: 16),
                  if (hasImage) const Icon(Icons.image, size: 16),
                  if (hasVideo) const Icon(Icons.videocam, size: 16),
                ],
              ),
            ),
            if (note.title.isNotEmpty)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
                child: Text(
                  note.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
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
    final hasText = note.title.isNotEmpty || note.content.isNotEmpty;
    final color = Color(note.colorValue);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color,
        child: hasImage
            ? const Icon(Icons.image)
            : hasAudio
                ? const Icon(Icons.mic)
                : hasVideo
                    ? const Icon(Icons.videocam)
                    : const Icon(Icons.text_snippet),
      ),
      title: Text(note.title.isNotEmpty ? note.title : '(No Title)'),
      subtitle: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 4,
        children: [
          if (hasText) const Icon(Icons.text_snippet, size: 14),
          if (hasAudio) const Icon(Icons.mic, size: 14),
          if (hasImage) const Icon(Icons.image, size: 14),
          if (hasVideo) const Icon(Icons.videocam, size: 14),
        ],
      ),
      trailing: Text(
        TimeOfDay.fromDateTime(note.createdAt).format(context),
        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
      ),
      onTap: onTap,
    );
  }
}
