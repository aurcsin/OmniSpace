// File: lib/services/omni_note_service.dart

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/omni_note.dart';
import '../models/attachment.dart';
import '../models/task.dart';
import '../models/goal.dart';
import '../models/event.dart';

/// Service to manage OmniNote CRUD and attachments using Hive.
class OmniNoteService extends ChangeNotifier {
  OmniNoteService._();
  static final OmniNoteService instance = OmniNoteService._();

  static const String _boxName = 'notes';
  late Box<OmniNote> _box;

  /// Initialize Hive box. Call once at app startup.
  Future<void> init() async {
    // Register note-related Hive adapters once
    if (!Hive.isAdapterRegistered(OmniNoteAdapter().typeId)) {
      Hive.registerAdapter(OmniNoteAdapter());
    }
    if (!Hive.isAdapterRegistered(ZoneThemeAdapter().typeId)) {
      Hive.registerAdapter(ZoneThemeAdapter());
    }
    if (!Hive.isAdapterRegistered(AttachmentAdapter().typeId)) {
      Hive.registerAdapter(AttachmentAdapter());
    }
    if (!Hive.isAdapterRegistered(TaskAdapter().typeId)) {
      Hive.registerAdapter(TaskAdapter());
    }
    if (!Hive.isAdapterRegistered(GoalAdapter().typeId)) {
      Hive.registerAdapter(GoalAdapter());
    }
    if (!Hive.isAdapterRegistered(EventAdapter().typeId)) {
      Hive.registerAdapter(EventAdapter());
    }

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

  /// Retrieve a note by its id, or null if it doesn't exist.
  OmniNote? getNoteById(String id) {
    return _box.get(id);
  }

  /// Full-text search on title, content, or tags.
  Future<List<OmniNote>> searchNotes(String query) async {
    await _ensureInit();
    final q = query.toLowerCase();
    return _box.values
        .where((n) =>
            n.title.toLowerCase().contains(q) ||
            n.content.toLowerCase().contains(q) ||
            n.tags.toLowerCase().contains(q))
        .toList();
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
