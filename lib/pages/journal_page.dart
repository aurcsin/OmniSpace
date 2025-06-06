// lib/pages/journal_page.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../models/omni_note.dart';
import '../models/attachment.dart';
import '../services/omni_note_service.dart';
import 'note_detail_page.dart';
import 'calendar_overview_page.dart';

/// JournalPage shows **all** notes, either as a ListTile or as a Masonry grid.
/// Each tile visually indicates which media/tasks/goals/events it contains,
/// plus color/mood/direction.
class JournalPage extends StatefulWidget {
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
        builder: (context, noteService, _) {
          final notes = _displayedNotes;

          return Scaffold(
            appBar: AppBar(
              title: Text('Journal'),
              actions: [
                IconButton(
                  icon: Icon(Icons.calendar_today),
                  tooltip: 'Calendar',
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => CalendarOverviewPage()),
                    );
                  },
                ),
                IconButton(
                  icon: Icon(_gridMode ? Icons.list : Icons.grid_view),
                  tooltip: _gridMode ? 'List View' : 'Grid View',
                  onPressed: () {
                    setState(() => _gridMode = !_gridMode);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.search),
                  tooltip: 'Search',
                  onPressed: () {
                    showSearch(
                      context: context,
                      delegate: _NoteSearchDelegate(
                        onSearch: (val) => _performSearch(val),
                        initial: _searchQuery,
                      ),
                    );
                  },
                ),
              ],
            ),
            body: Column(
              children: [
                if (_isLoading)
                  Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (notes.isEmpty)
                  Expanded(
                    child: Center(
                      child: Text(
                        _searchQuery.isEmpty
                            ? 'No notes yet.\nTap + to create one.'
                            : 'No notes match your search.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: _gridMode
                          ? MasonryGridView.count(
                              crossAxisCount: 2,
                              mainAxisSpacing: 8,
                              crossAxisSpacing: 8,
                              itemCount: notes.length,
                              itemBuilder: (context, index) {
                                final note = notes[index];
                                return _NoteCard(
                                  note: note,
                                  onTap: () {
                                    Navigator.of(context)
                                        .push(
                                          MaterialPageRoute(
                                            builder: (_) => NoteDetailPage(
                                              omniNote: note,
                                            ),
                                          ),
                                        )
                                        .then((_) => _initializeNotes());
                                  },
                                );
                              },
                            )
                          : ListView.separated(
                              itemCount: notes.length,
                              separatorBuilder: (_, __) => Divider(height: 1),
                              itemBuilder: (context, index) {
                                final note = notes[index];
                                return _NoteListTile(
                                  note: note,
                                  onTap: () {
                                    Navigator.of(context)
                                        .push(
                                          MaterialPageRoute(
                                            builder: (_) => NoteDetailPage(
                                              omniNote: note,
                                            ),
                                          ),
                                        )
                                        .then((_) => _initializeNotes());
                                  },
                                );
                              },
                            ),
                    ),
                  ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              child: Icon(Icons.add),
              tooltip: 'Create New Note',
              onPressed: () {
                _showCreateNoteOptions(context);
              },
            ),
          );
        },
      ),
    );
  }

  /// Show the bottom‐sheet with four options: Text, Audio, Image, Video.
  void _showCreateNoteOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
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
                              NoteDetailPage(initialMode: NoteMode.text),
                        ),
                      )
                      .then((_) => _initializeNotes());
                },
              ),
              _buildOptionIcon(
                icon: Icons.mic,
                label: 'Audio Note',
                color: Colors.redAccent,
                onTap: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context)
                      .push(
                        MaterialPageRoute(
                          builder: (_) =>
                              NoteDetailPage(initialMode: NoteMode.voice),
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
                              NoteDetailPage(initialMode: NoteMode.image),
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
                              NoteDetailPage(initialMode: NoteMode.video),
                        ),
                      )
                      .then((_) => _initializeNotes());
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOptionIcon({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
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
            SizedBox(height: 8),
            Text(label),
          ],
        ),
      ),
    );
  }
}

/// ─────────────────────────────────────────────────────────────────────────────
/// A small “card” for the masonry grid. Shows either the first image thumbnail
/// or, if no image, a white card with colored left border + icons for any media
/// or metadata (text, audio, image, video, mood, direction, tasks, goals, events)
/// ─────────────────────────────────────────────────────────────────────────────
class _NoteCard extends StatelessWidget {
  final OmniNote note;
  final VoidCallback onTap;
  const _NoteCard({required this.note, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hasImage = note.attachments.any((a) => a.type == AttachmentType.image);
    final hasAudio = note.attachments.any((a) => a.type == AttachmentType.audio);
    final hasVideo = note.attachments.any((a) => a.type == AttachmentType.video);
    final hasText = note.title.isNotEmpty || note.content.isNotEmpty;
    final hasTasks = note.tasks?.isNotEmpty == true;
    final hasGoals = note.goals?.isNotEmpty == true;
    final hasEvents = note.events?.isNotEmpty == true;
    final hasMood = (note.mood != null && note.mood!.isNotEmpty);
    final hasDirection = (note.direction != null && note.direction!.isNotEmpty);
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
            // If the note has any image attachments, show the first image as a preview:
            if (hasImage)
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(5)),
                child: Image.file(
                  File(
                    note.attachments.firstWhere((a) => a.type == AttachmentType.image).localPath,
                  ),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 150,
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (hasText)
                    Text(
                      note.title.isNotEmpty ? note.title : '(No Title)',
                      style: TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (note.subtitle.isNotEmpty)
                    Text(
                      note.subtitle,
                      style: TextStyle(color: Colors.grey[700]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  SizedBox(height: 4),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 4,
                    children: [
                      if (hasText) Icon(Icons.text_snippet, size: 16),
                      if (hasAudio) Icon(Icons.mic, size: 16),
                      if (hasImage) Icon(Icons.image, size: 16),
                      if (hasVideo) Icon(Icons.videocam, size: 16),
                      if (hasMood) Chip(label: Text(note.mood!)),
                      if (hasDirection) Icon(Icons.explore, size: 16),
                      if (hasTasks) Icon(Icons.checklist, size: 16),
                      if (hasGoals) Icon(Icons.flag, size: 16),
                      if (hasEvents) Icon(Icons.event, size: 16),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    TimeOfDay.fromDateTime(note.createdAt).format(context),
                    style: TextStyle(fontSize: 10, color: Colors.grey[600]),
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

/// ─────────────────────────────────────────────────────────────────────────────
/// A simple ListTile version of a note. Similar icons + color dot.
/// ─────────────────────────────────────────────────────────────────────────────
class _NoteListTile extends StatelessWidget {
  final OmniNote note;
  final VoidCallback onTap;
  const _NoteListTile({required this.note, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hasImage = note.attachments.any((a) => a.type == AttachmentType.image);
    final hasAudio = note.attachments.any((a) => a.type == AttachmentType.audio);
    final hasVideo = note.attachments.any((a) => a.type == AttachmentType.video);
    final hasText = note.title.isNotEmpty || note.content.isNotEmpty;
    final hasTasks = note.tasks?.isNotEmpty == true;
    final hasGoals = note.goals?.isNotEmpty == true;
    final hasEvents = note.events?.isNotEmpty == true;
    final hasMood = (note.mood != null && note.mood!.isNotEmpty);
    final hasDirection = (note.direction != null && note.direction!.isNotEmpty);
    final color = Color(note.colorValue);

    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: color,
        child: hasImage
            ? Icon(Icons.image)
            : hasAudio
                ? Icon(Icons.mic)
                : hasVideo
                    ? Icon(Icons.videocam)
                    : Icon(Icons.text_snippet),
      ),
      title: Text(note.title.isNotEmpty ? note.title : '(No Title)'),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (note.subtitle.isNotEmpty)
            Text(
              note.subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          SizedBox(height: 4),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 4,
            children: [
              if (hasText) Icon(Icons.text_snippet, size: 14),
              if (hasAudio) Icon(Icons.mic, size: 14),
              if (hasImage) Icon(Icons.image, size: 14),
              if (hasVideo) Icon(Icons.videocam, size: 14),
              if (hasMood) Chip(label: Text(note.mood!)),
              if (hasDirection) Icon(Icons.explore, size: 14),
              if (hasTasks) Icon(Icons.checklist, size: 14),
              if (hasGoals) Icon(Icons.flag, size: 14),
              if (hasEvents) Icon(Icons.event, size: 14),
            ],
          ),
        ],
      ),
      trailing: Text(
        TimeOfDay.fromDateTime(note.createdAt).format(context),
        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
      ),
    );
  }
}

/// ─────────────────────────────────────────────────────────────────────────────
/// A SearchDelegate that calls `onSearch(query)` on every submit.
/// ─────────────────────────────────────────────────────────────────────────────
class _NoteSearchDelegate extends SearchDelegate {
  final void Function(String) onSearch;
  final String initial;

  _NoteSearchDelegate({required this.onSearch, required this.initial})
      : super(
          searchFieldLabel: initial.isNotEmpty ? initial : 'Search notes…',
          textInputAction: TextInputAction.search,
        );

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: Icon(Icons.clear),
          onPressed: () {
            query = '';
          },
        )
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    onSearch(query);
    close(context, null);
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container();
  }
}
