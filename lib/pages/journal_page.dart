// lib/pages/journal_page.dart

import 'dart:io'; // For File in thumbnails, etc.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/omni_note.dart';        // For ZoneTheme, OmniNote
import '../models/attachment.dart';       // For AttachmentType
import '../services/omni_note_service.dart';
import 'note_detail_page.dart';           // For NoteDetailPage and NoteMode
import 'calendar_overview_page.dart';

class JournalPage extends StatefulWidget {
  @override
  _JournalPageState createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  String _searchQuery = '';
  bool _isLoading = true;
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
              title: Text('Ultimate Journal Hub'),
              actions: [
                IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => CalendarOverviewPage()),
                    );
                  },
                ),
                IconButton(
                  icon: Icon(Icons.search),
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
                  Expanded(child: Center(child: CircularProgressIndicator()))
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
                      child: MasonryGridView.count(
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

  /// Show a modal bottom sheet with four large icons: Text, Voice, Image, Video
  void _showCreateNoteOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
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
                          builder: (_) => NoteDetailPage(
                            initialMode: NoteMode.text,
                          ),
                        ),
                      )
                      .then((_) => _initializeNotes());
                },
              ),
              _buildOptionIcon(
                icon: Icons.mic,
                label: 'Voice Note',
                color: Colors.redAccent,
                onTap: () {
                  Navigator.of(ctx).pop();
                  _createAudioNote();
                },
              ),
              _buildOptionIcon(
                icon: Icons.camera_alt,
                label: 'Image Note',
                color: Colors.teal,
                onTap: () {
                  Navigator.of(ctx).pop();
                  _createImageNote();
                },
              ),
              _buildOptionIcon(
                icon: Icons.videocam,
                label: 'Video Note',
                color: Colors.blueAccent,
                onTap: () {
                  Navigator.of(ctx).pop();
                  _createVideoNote();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// Helper to build one of the four options in the modal sheet
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

  /// Create a brand-new note with an **image** attachment only:
  /// 1) Let user pick/capture an image
  /// 2) Create an empty OmniNote shell, then immediately add the image
  /// 3) Navigate to NoteDetailPage so user can add title/zone/tags, etc.
  Future<void> _createImageNote() async {
    // 1) Request permissions & pick image
    final cameraPerm = await Permission.camera.request();
    final galleryPerm = await Permission.photos.request();
    if (cameraPerm != PermissionStatus.granted &&
        galleryPerm != PermissionStatus.granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Camera or gallery permission denied.')),
      );
      return;
    }

    final picked = await ImagePicker()
        .pickImage(source: ImageSource.camera, imageQuality: 80);
    if (picked == null) return;
    final imageFile = File(picked.path);

    // 2) Create a “blank” OmniNote with default values
    final newNote = OmniNote(
      title: '',
      subtitle: '',
      content: '',
      zone: ZoneTheme.Fusion,
      recommendedTag: null,
      tags: '',
      attachments: [],
    );
    await OmniNoteService.instance.createNote(newNote);

    // 3) Immediately attach the picked image
    await OmniNoteService.instance.addImageAttachment(newNote, imageFile);

    // 4) Open NoteDetailPage for the user to finish filling out metadata
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => NoteDetailPage(omniNote: newNote),
          ),
        )
        .then((_) => _initializeNotes());
  }

  /// Create a new note with an **audio** (voice) attachment only:
  /// 1) Navigate to NoteDetailPage with mode=voice so they can record
  Future<void> _createAudioNote() async {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => NoteDetailPage(initialMode: NoteMode.voice),
          ),
        )
        .then((_) => _initializeNotes());
  }

  /// Create a new note with a **video** attachment only:
  /// 1) Request permissions & pick/capture a video
  /// 2) Create an empty OmniNote shell, attach the video, then open NoteDetailPage
  Future<void> _createVideoNote() async {
    final cameraPerm = await Permission.camera.request();
    final micPerm = await Permission.microphone.request();
    if (cameraPerm != PermissionStatus.granted ||
        micPerm != PermissionStatus.granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Camera/microphone permission denied.')),
      );
      return;
    }

    final picked = await ImagePicker().pickVideo(
      source: ImageSource.camera,
      maxDuration: Duration(minutes: 5),
    );
    if (picked == null) return;
    final videoFile = File(picked.path);

    // 2) Create a blank OmniNote
    final newNote = OmniNote(
      title: '',
      subtitle: '',
      content: '',
      zone: ZoneTheme.Fusion,
      recommendedTag: null,
      tags: '',
      attachments: [],
    );
    await OmniNoteService.instance.createNote(newNote);

    // 3) Attach the captured video
    await OmniNoteService.instance.addVideoAttachment(newNote, videoFile);

    // 4) Go to NoteDetailPage in video mode
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => NoteDetailPage(
              omniNote: newNote,
              initialMode: NoteMode.video,
            ),
          ),
        )
        .then((_) => _initializeNotes());
  }
}

/// A small “card” widget to visually represent one OmniNote in the grid.
/// Shows thumbnail or icon depending on first attachment type.
class _NoteCard extends StatelessWidget {
  final OmniNote note;
  final VoidCallback onTap;
  const _NoteCard({required this.note, required this.onTap});

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (note.attachments.isNotEmpty) {
      final first = note.attachments.first;
      switch (first.type) {
        case AttachmentType.image:
          content = Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(first.localPath),
                  fit: BoxFit.cover,
                  height: 160,
                  width: double.infinity,
                ),
              ),
              Positioned(
                bottom: 4,
                left: 4,
                right: 4,
                child: Container(
                  color: Colors.black54,
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Text(
                    note.title.isNotEmpty ? note.title : 'Image Note',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          );
          break;
        case AttachmentType.audio:
          content = Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.blueGrey.shade100,
            ),
            height: 160,
            child: Center(
              child: Icon(Icons.mic, size: 48, color: Colors.blueGrey.shade700),
            ),
          );
          break;
        case AttachmentType.video:
          content = Stack(
            children: [
              if (first.thumbnailPath != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(first.thumbnailPath!),
                    fit: BoxFit.cover,
                    height: 160,
                    width: double.infinity,
                  ),
                )
              else
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.black26,
                  ),
                  height: 160,
                  child: Center(
                    child: Icon(Icons.videocam, size: 48, color: Colors.white70),
                  ),
                ),
              Positioned(
                bottom: 4,
                right: 4,
                child: Icon(Icons.play_circle_fill, color: Colors.white70, size: 28),
              ),
            ],
          );
          break;
      }
    } else {
      // Fallback: show the title/content if no attachments
      content = Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey.shade200,
        ),
        constraints: BoxConstraints(minHeight: 160),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              note.title.isNotEmpty ? note.title : 'Text Note',
              style: TextStyle(fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 4),
            Text(
              note.subtitle.isNotEmpty
                  ? note.subtitle
                  : (note.content.length > 80
                      ? note.content.substring(0, 80) + '…'
                      : note.content),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: content,
      ),
    );
  }
}

/// A simple search delegate to prompt user to enter a query.
/// When “search” is submitted, it calls onSearch(query) and closes.
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
    return Container(); // Could show recent searches or tags
  }
}
