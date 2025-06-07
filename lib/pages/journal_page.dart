// lib/pages/journal_page.dart

import 'dart:io';

import 'package:flutter/material.dart';

import '../models/omni_note.dart';
import '../models/attachment.dart';
import '../services/omni_note_service.dart';
import 'note_detail_page.dart';
import 'calendar_overview_page.dart';

/// JournalPage shows **all** notes, either as a ListTile or in a 2-column grid.
class JournalPage extends StatefulWidget {
  const JournalPage({Key? key}) : super(key: key);

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
    final notes = _displayedNotes;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            tooltip: 'Calendar',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CalendarOverviewPage()),
              );
            },
          ),
          IconButton(
            icon: Icon(_gridMode ? Icons.list : Icons.grid_view),
            tooltip: _gridMode ? 'List View' : 'Grid View',
            onPressed: () => setState(() => _gridMode = !_gridMode),
          ),
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search',
            onPressed: () {
              showSearch(
                context: context,
                delegate: _NoteSearchDelegate(
                  onSearch: _performSearch,
                  initial: _searchQuery,
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : notes.isEmpty
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
                      ? GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 8,
                            childAspectRatio: 0.75,
                          ),
                          itemCount: notes.length,
                          itemBuilder: (context, index) {
                            final note = notes[index];
                            return _NoteCard(
                              note: note,
                              onTap: () => Navigator.of(context)
                                  .push(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          NoteDetailPage(omniNote: note),
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
                          itemBuilder: (context, index) {
                            final note = notes[index];
                            return _NoteListTile(
                              note: note,
                              onTap: () => Navigator.of(context)
                                  .push(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          NoteDetailPage(omniNote: note),
                                    ),
                                  )
                                  .then((_) => _initializeNotes()),
                            );
                          },
                        ),
                ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Create New Note',
        onPressed: () => _showCreateNoteOptions(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCreateNoteOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
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
                    .push(
                      MaterialPageRoute(
                        builder: (_) =>
                            const NoteDetailPage(initialMode: NoteMode.text),
                      ),
                    )
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
                    .push(
                      MaterialPageRoute(
                        builder: (_) =>
                            const NoteDetailPage(initialMode: NoteMode.image),
                      ),
                    )
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
                    .push(
                      MaterialPageRoute(
                        builder: (_) =>
                            const NoteDetailPage(initialMode: NoteMode.video),
                      ),
                    )
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
  }) {
    return Padding(
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
}

/// ────────────────────────────────────────────────────────────────────────────
/// A small “card” for the grid view.
/// ────────────────────────────────────────────────────────────────────────────
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
    final hasMood =
        (note.mood != null && note.mood!.isNotEmpty);
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
                  File(note.attachments
                      .firstWhere((a) => a.type == AttachmentType.image)
                      .localPath),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 120,
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (hasText)
                    Text(
                      note.title.isNotEmpty ? note.title : '(No Title)',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 4),
                  Wrap(spacing: 4, children: [
                    if (hasText) const Icon(Icons.text_snippet, size: 16),
                    if (hasAudio) const Icon(Icons.mic, size: 16),
                    if (hasVideo) const Icon(Icons.videocam, size: 16),
                    if (hasMood) Chip(label: Text(note.mood!)),
                  ]),
                  const SizedBox(height: 4),
                  Text(
                    TimeOfDay.fromDateTime(note.createdAt).format(context),
                    style:
                        TextStyle(fontSize: 10, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ────────────────────────────────────────────────────────────────────────────
/// A simple ListTile for the list view.
/// ────────────────────────────────────────────────────────────────────────────
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
    final hasMood =
        (note.mood != null && note.mood!.isNotEmpty);
    final color = Color(note.colorValue);

    return ListTile(
      onTap: onTap,
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
      subtitle: Wrap(spacing: 4, children: [
        if (hasText) const Icon(Icons.text_snippet, size: 14),
        if (hasAudio) const Icon(Icons.mic, size: 14),
        if (hasVideo) const Icon(Icons.videocam, size: 14),
        if (hasMood) Chip(label: Text(note.mood!)),
      ]),
      trailing: Text(
        TimeOfDay.fromDateTime(note.createdAt).format(context),
        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
      ),
    );
  }
}

/// ────────────────────────────────────────────────────────────────────────────
/// A SearchDelegate that calls `onSearch(query)`.
/// ────────────────────────────────────────────────────────────────────────────
class _NoteSearchDelegate extends SearchDelegate<void> {
  final Future<void> Function(String) onSearch;
  final String initial;

  _NoteSearchDelegate({required this.onSearch, required this.initial})
      : super(searchFieldLabel: initial.isNotEmpty ? initial : 'Search…');

  @override
  List<Widget>? buildActions(BuildContext context) => [
        if (query.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () => query = '',
          )
      ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => close(context, null),
      );

  @override
  Widget buildResults(BuildContext context) {
    onSearch(query);
    close(context, null);
    return const SizedBox.shrink();
  }

  @override
  Widget buildSuggestions(BuildContext context) => const SizedBox.shrink();
}
