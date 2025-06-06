// lib/services/omni_note_service.dart

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/omni_note.dart';
import 'garden_service.dart';
import 'stats_service.dart';
import 'spirit_buddy_service.dart';

class OmniNoteService extends ChangeNotifier {
  OmniNoteService._();
  static final OmniNoteService instance = OmniNoteService._();

  static const String _boxName = 'omni_notes_box';
  Box<OmniNote>? _box;

  final List<OmniNote> _notes = [];
  List<OmniNote> get notes => List.unmodifiable(_notes);

  /// ------------------------------------------------------
  /// initHive()
  ///
  /// MUST be called *after* adapters have been registered in main().
  /// Simply open the box and load existing notes into memory.
  /// ------------------------------------------------------
  Future<void> initHive() async {
    // DO NOT call Hive.initFlutter() or Hive.registerAdapter() here!
    // They should live in main.dart only.

    // 1) Open (or create) the box
    _box = await Hive.openBox<OmniNote>(_boxName);

    // 2) Load all existing notes into the in-memory list
    _notes
      ..clear()
      ..addAll(
        _box!.values.toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
      );
    notifyListeners();
  }

  /// Load all notes from the box into memory
  Future<void> loadAllNotes() async {
    if (_box == null) {
      await initHive();
      return;
    }
    _notes
      ..clear()
      ..addAll(
        _box!.values.toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
      );
    notifyListeners();
  }

  /// Create a new note
  Future<void> createNote(OmniNote note) async {
    if (_box == null) await initHive();
    await _box!.add(note);
    await GardenService.instance.addFlowerFromEntry(note);
    await StatsService.instance.updateStatsForEntry(note);
    SpiritBuddyService.instance.reflectOnEntry(note);
    await loadAllNotes();
  }

  /// Update an existing note
  Future<void> updateNote(OmniNote note) async {
    if (_box == null) await initHive();
    await note.save();
    await GardenService.instance.addFlowerFromEntry(note);
    await StatsService.instance.updateStatsForEntry(note);
    SpiritBuddyService.instance.reflectOnEntry(note);
    await loadAllNotes();
  }

  /// Delete a note
  Future<void> deleteNote(OmniNote note) async {
    if (_box == null) await initHive();
    await note.delete();
    await loadAllNotes();
  }

  /// Search notes (returns a new filtered list)
  Future<List<OmniNote>> searchNotes(String query) async {
    if (_box == null) await initHive();
    final lowerQ = query.toLowerCase().trim();
    if (lowerQ.isEmpty) {
      return _box!.values.toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    final results = _box!.values.where((note) {
      final inTitle = note.title.toLowerCase().contains(lowerQ);
      final inSub = note.subtitle.toLowerCase().contains(lowerQ);
      final inContent = note.content.toLowerCase().contains(lowerQ);
      final inTags = note.tags.toLowerCase().contains(lowerQ);
      final inRecTag = note.recommendedTag?.toLowerCase().contains(lowerQ) ?? false;
      return inTitle || inSub || inContent || inTags || inRecTag;
    }).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return results;
  }
}
