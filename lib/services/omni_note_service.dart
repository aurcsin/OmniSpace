// File: lib/services/omni_note_service.dart

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/omni_note.dart';
import '../models/attachment.dart';
import 'tracker_service.dart';

/// Service to manage OmniNote CRUD and attachments using Hive.
class OmniNoteService extends ChangeNotifier {
  OmniNoteService._();
  static final OmniNoteService instance = OmniNoteService._();

  static const String _boxName = 'notes';
  late Box<OmniNote> _box;

  /// Initialize Hive box. Call once at app startup.
  Future<void> init() async {
    _box = await Hive.openBox<OmniNote>(_boxName);
    notifyListeners();
  }

  Future<void> _ensureInit() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await init();
    }
  }

  /// All notes in insertion order.
  List<OmniNote> get notes {
    return _box.values.toList();
  }

  /// Reloads notes (no-op for Hive, but matches API).
  Future<void> loadAllNotes() async {
    await _ensureInit();
    notifyListeners();
  }

  /// Full-text search on title, content, tags, and linked trackers.
  Future<List<OmniNote>> searchNotes(String query) async {
    await _ensureInit();
    final q = query.toLowerCase();
    final trackers = TrackerService.instance.all;
    return _box.values.where((n) {
      final trackerIds = TrackerService.instance.linkedTo(n.id);
      final trackerTitles = trackers
          .where((t) => trackerIds.contains(t.id))
          .map((t) => t.title.toLowerCase());
      final trackerMatch =
          trackerTitles.any((title) => title.contains(q));
      return n.title.toLowerCase().contains(q) ||
          n.content.toLowerCase().contains(q) ||
          n.tags.toLowerCase().contains(q) ||
          trackerMatch;
    }).toList();
  }

  /// Create or update a note based on its Hive key.
  Future<void> saveNote(OmniNote note) async {
    await _ensureInit();
    // Use note.id as key for consistency
    await _box.put(note.id, note);
    notifyListeners();
  }

  /// Delete a note by its id.
  Future<void> deleteNoteById(String id) async {
    await _ensureInit();
    await _box.delete(id);
    notifyListeners();
  }

  // Attachment helpers:
  Future<void> addImageAttachment(OmniNote note, File file) async {
    await _ensureInit();
    note.attachments.add(
      Attachment(type: AttachmentType.image, localPath: file.path),
    );
    await saveNote(note);
  }

  Future<void> addAudioAttachment(OmniNote note, File file) async {
    await _ensureInit();
    note.attachments.add(
      Attachment(type: AttachmentType.audio, localPath: file.path),
    );
    await saveNote(note);
  }

  Future<void> addVideoAttachment(OmniNote note, File file) async {
    await _ensureInit();
    note.attachments.add(
      Attachment(type: AttachmentType.video, localPath: file.path),
    );
    await saveNote(note);
  }
}
