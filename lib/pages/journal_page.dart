// lib/pages/journal_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/omni_note_service.dart';
import '../models/omni_note.dart';
import 'note_detail_page.dart';

class JournalPage extends StatefulWidget {
  @override
  _JournalPageState createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  String _searchQuery = '';
  bool _isLoading = true;

  /// This local list holds exactly what we display (all notes or filtered results).
  List<OmniNote> _displayedNotes = [];

  @override
  void initState() {
    super.initState();
    _initializeNotes();
  }

  Future<void> _initializeNotes() async {
    // 1) Ensure Hive is initialized and notes are loaded into the service
    await OmniNoteService.instance.loadAllNotes();

    // 2) Copy all notes from the service into our local displayed list
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

    // 1) Get filtered results from the service
    final results = await OmniNoteService.instance.searchNotes(query);

    // 2) Update our local displayed list (no touching of private _notes)
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
          // We use _displayedNotes (not noteService.notes) so that search results stay persistent
          final notes = _displayedNotes;

          return Scaffold(
            appBar: AppBar(
              title: Text('Journal'),
              actions: [
                IconButton(
                  icon: Icon(Icons.filter_list),
                  onPressed: () {
                    // TODO: Show filter dialog (e.g. filter by zone or date)
                  },
                ),
                PopupMenuButton<String>(
                  onSelected: (val) {
                    if (val == 'Clear') {
                      setState(() {
                        _searchQuery = '';
                        _isLoading = true;
                      });
                      _performSearch('');
                    }
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'Clear',
                      child: Text('Clear Search'),
                    ),
                  ],
                ),
              ],
            ),
            body: Column(
              children: [
                // 1) Search bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Search notes…',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      isDense: true,
                    ),
                    onChanged: (val) {
                      _searchQuery = val;
                    },
                    onSubmitted: (val) {
                      _performSearch(val);
                    },
                  ),
                ),

                // 2) Loading / No-notes / List
                if (_isLoading)
                  Expanded(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (notes.isEmpty)
                  Expanded(
                    child: Center(
                      child: Text(
                        _searchQuery.isEmpty
                            ? 'No notes yet.\nTap the + button to add one.'
                            : 'No notes match your criteria.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.separated(
                      itemCount: notes.length,
                      separatorBuilder: (_, __) => Divider(height: 1),
                      itemBuilder: (context, index) {
                        final note = notes[index];
                        return ListTile(
                          title: Text(note.title),
                          subtitle: Text(
                            note.subtitle.isNotEmpty
                                ? note.subtitle
                                : (note.content.length > 50
                                    ? note.content.substring(0, 50) + '…'
                                    : note.content),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (note.recommendedTag != null)
                                Text(
                                  note.recommendedTag!,
                                  style: TextStyle(
                                    color: Colors.blueAccent,
                                    fontSize: 12,
                                  ),
                                ),
                              SizedBox(height: 4),
                              Text(
                                _formatZone(note.zone),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    NoteDetailPage(omniNote: note),
                              ),
                            ).then((_) {
                              // When returning from the detail page, refresh the list
                              _initializeNotes();
                            });
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              child: Icon(Icons.add),
              tooltip: 'New Note',
              onPressed: () {
                Navigator.of(context)
                    .push(
                      MaterialPageRoute(builder: (_) => NoteDetailPage()),
                    )
                    .then((_) {
                      // After coming back from “New Note”, reload all notes
                      _initializeNotes();
                    });
              },
            ),
          );
        },
      ),
    );
  }

  String _formatZone(ZoneTheme zone) {
    switch (zone) {
      case ZoneTheme.Air:
        return 'Air';
      case ZoneTheme.Earth:
        return 'Earth';
      case ZoneTheme.Fire:
        return 'Fire';
      case ZoneTheme.Water:
        return 'Water';
      case ZoneTheme.Void:
        return 'Void';
      case ZoneTheme.Fusion:
        return 'Fusion';
    }
  }
}
