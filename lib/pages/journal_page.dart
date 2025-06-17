import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../models/omni_note.dart';
import '../models/attachment.dart';
import '../services/omni_note_service.dart';
import '../widgets/main_menu_drawer.dart';
import 'calendar_overview_page.dart';
import 'note_view_page.dart';
import 'note_detail_page.dart';

/// JournalPage shows all notes either in a grid or list, with tag-filtering.
class JournalPage extends StatefulWidget {
  const JournalPage({super.key});

  @override
  _JournalPageState createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  String _searchQuery = '';
  bool _isLoading = true;
  bool _gridMode = true;
  List<OmniNote> _allNotes = [];
  List<OmniNote> _displayedNotes = [];
  final Set<String> _selectedTags = {};

  @override
  void initState() {
    super.initState();
    _initializeNotes();
  }

  Future<void> _initializeNotes() async {
    await OmniNoteService.instance.loadAllNotes();
    _allNotes = OmniNoteService.instance.notes;
    _applyFilters();
    setState(() => _isLoading = false);
  }

  void _applyFilters() {
    _displayedNotes = _allNotes.where((n) {
      final matchesSearch = _searchQuery.isEmpty ||
          n.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          n.content.toLowerCase().contains(_searchQuery.toLowerCase());
      final tags = n.tags
          .split(',')
          .map((t) => t.trim().toLowerCase())
          .where((t) => t.isNotEmpty);
      final matchesTags = _selectedTags.isEmpty ||
          tags.any((t) => _selectedTags.contains(t));
      return matchesSearch && matchesTags;
    }).toList();
  }

  void _onSearchChanged(String q) {
    setState(() {
      _searchQuery = q;
      _applyFilters();
    });
  }

  @override
  Widget build(BuildContext context) {
    // collect all unique tags
    final allTags = {
      for (var n in _allNotes)
        ...n.tags
            .split(',')
            .map((t) => t.trim().toLowerCase())
            .where((t) => t.isNotEmpty)
    };

    return ChangeNotifierProvider.value(
      value: OmniNoteService.instance,
      child: Scaffold(
        drawer: const MainMenuDrawer(),
        appBar: AppBar(
          title: const Text('Journal'),
          actions: [
            IconButton(
              icon: const Icon(Icons.calendar_today),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CalendarOverviewPage()),
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
                  // Search field
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: TextField(
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: 'Search…',
                      ),
                      onChanged: _onSearchChanged,
                    ),
                  ),

                  // Tag chips
                  if (allTags.isNotEmpty)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        children: allTags.map((tag) {
                          final sel = _selectedTags.contains(tag);
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text('#$tag'),
                              selected: sel,
                              onSelected: (on) => setState(() {
                                if (on) _selectedTags.add(tag);
                                else _selectedTags.remove(tag);
                                _applyFilters();
                              }),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                  // Notes grid/list
                  Expanded(
                    child: _displayedNotes.isEmpty
                        ? Center(
                            child: Text(
                              _searchQuery.isEmpty && _selectedTags.isEmpty
                                  ? 'No notes yet.'
                                  : 'No notes match your filters.',
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
                                    itemCount: _displayedNotes.length,
                                    itemBuilder: (_, i) {
                                      final note = _displayedNotes[i];
                                      return _NoteCard(
                                        note: note,
                                        onTap: () => Navigator.of(context)
                                            .push(
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    NoteViewPage(note: note),
                                              ),
                                            )
                                            .then((_) => _initializeNotes()),
                                      );
                                    },
                                  )
                                : ListView.separated(
                                    itemCount: _displayedNotes.length,
                                    separatorBuilder: (_, __) =>
                                        const Divider(height: 1),
                                    itemBuilder: (_, i) {
                                      final note = _displayedNotes[i];
                                      return _NoteListTile(
                                        note: note,
                                        onTap: () => Navigator.of(context)
                                            .push(
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    NoteViewPage(note: note),
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
          onPressed: () => Navigator.of(context)
              .push(
                MaterialPageRoute(
                  builder: (_) => const NoteDetailPage(omniNote: null),
                ),
              )
              .then((_) => _initializeNotes()),
        ),
      ),
    );
  }
}

/// Grid‐card
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
    final color = Color(note.colorValue);

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
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
                      File(note
                          .attachments
                          .firstWhere((a) => a.type == AttachmentType.image)
                          .localPath),
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 150,
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Wrap(
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
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
          if (note.isPinned)
            const Positioned(top: 4, right: 4, child: Icon(Icons.push_pin, size: 16)),
          if (note.isStarred)
            const Positioned(
                top: 4, left: 4, child: Icon(Icons.star, size: 16, color: Colors.amber)),
        ],
      ),
    );
  }
}

/// List‐tile
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
        spacing: 4,
        children: [
          if (hasText) const Icon(Icons.text_snippet, size: 14),
          if (hasAudio) const Icon(Icons.mic, size: 14),
          if (hasImage) const Icon(Icons.image, size: 14),
          if (hasVideo) const Icon(Icons.videocam, size: 14),
        ],
      ),
      trailing: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (note.isPinned) const Icon(Icons.push_pin, size: 16),
          if (note.isStarred) const Icon(Icons.star, size: 16, color: Colors.amber),
          Text(
            TimeOfDay.fromDateTime(note.createdAt).format(context),
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}
